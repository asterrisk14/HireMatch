using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using HireMatch.Services.Database;
using Stripe;
using System;
using System.IO;
using System.Threading.Tasks;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("api/stripe")]
    public class StripeWebhookController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly ILogger<StripeWebhookController> _logger;
        private readonly HireMatchDbContext _context;

        public StripeWebhookController(IConfiguration config, ILogger<StripeWebhookController> logger, HireMatchDbContext context)
        {
            _config = config;
            _logger = logger;
            _context = context;
        }

        [HttpPost("webhook")]
        [IgnoreAntiforgeryToken]
        [AllowAnonymous]
        public async Task<IActionResult> Webhook()
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
            var signatureHeader = Request.Headers["Stripe-Signature"];
            var webhookSecret = _config["Stripe:WebhookSecret"];

            if (string.IsNullOrWhiteSpace(webhookSecret))
            {
                _logger.LogError("Stripe webhook secret is not configured.");
                return BadRequest("Stripe webhook secret is not configured");
            }

            Event stripeEvent;
            try
            {
                stripeEvent = EventUtility.ConstructEvent(json, signatureHeader, webhookSecret, throwOnApiVersionMismatch: false);
            }
            catch (StripeException ex)
            {
                _logger.LogWarning(ex, "Stripe webhook verification failed.");
                return BadRequest();
            }

            var alreadyProcessed = await _context.PremiumPayments
                .AnyAsync(p => p.WebhookEventId == stripeEvent.Id);
            if (alreadyProcessed)
            {
                _logger.LogInformation("Webhook event {EventId} already processed, skipping.", stripeEvent.Id);
                return Ok();
            }

            if (stripeEvent.Type == EventTypes.PaymentIntentSucceeded)
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                if (paymentIntent?.Id != null)
                {
                    if (paymentIntent.Metadata.TryGetValue("userId", out var userIdStr) && int.TryParse(userIdStr, out var userId))
                    {
                        _logger.LogInformation("Uspješna uplata za korisnika ID: {UserId}.", userId);

                        var user = await _context.MyAppUsers.FirstOrDefaultAsync(x => x.Id == userId);
                        if (user != null && !user.IsPremium)
                        {
                            user.IsPremium = true;

                            var payment = await _context.PremiumPayments
                                .FirstOrDefaultAsync(p => p.PaymentIntentId == paymentIntent.Id);

                            if (payment != null)
                            {
                                payment.Status = "completed";
                                payment.ConfirmedAt = DateTime.UtcNow;
                                payment.WebhookEventId = stripeEvent.Id;
                            }
                            else
                            {
                                _context.PremiumPayments.Add(new PremiumPayment
                                {
                                    UserId = userId,
                                    PaymentIntentId = paymentIntent.Id,
                                    WebhookEventId = stripeEvent.Id,
                                    Amount = paymentIntent.Amount / 100m,
                                    Currency = paymentIntent.Currency,
                                    Status = "completed",
                                    CreatedAt = DateTime.UtcNow,
                                    ConfirmedAt = DateTime.UtcNow
                                });
                            }

                            _context.Notifications.Add(new Notification
                            {
                                UserId = userId,
                                Type = "Payment",
                                Message = "Your Premium membership has been activated successfully!",
                                IsRead = false,
                                CreatedAt = DateTime.UtcNow
                            });

                            await _context.SaveChangesAsync();
                            _logger.LogInformation("Korisnik {UserId} je uspješno nadograđen na Premium.", userId);
                        }
                    }
                }
            }

            return Ok();
        }
    }
}