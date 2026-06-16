using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
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
        [EnableRateLimiting("stripe_webhook")]
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

            if (stripeEvent.Type == EventTypes.PaymentIntentSucceeded)
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                if (paymentIntent?.Id != null)
                {
                    // Izvlačimo userId iz uplate
                    if (paymentIntent.Metadata.TryGetValue("userId", out var userIdStr) && int.TryParse(userIdStr, out var userId))
                    {
                        _logger.LogInformation("Uspješna uplata za korisnika ID: {UserId}. Aktiviram Premium...", userId);
                        
                        var user = await _context.MyAppUsers.FirstOrDefaultAsync(x => x.Id == userId);
                        if (user != null)
                        {
                            user.IsPremium = true; // Korisnik postaje Premium član!
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