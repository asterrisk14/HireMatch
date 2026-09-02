using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Database;
using HireMatch.Model.Responses;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;

namespace HireMatch.Services.Implementations
{
    public class PaymentService : IPaymentService
    {
        private readonly HireMatchDbContext _context;
        private readonly IConfiguration _configuration;

        public PaymentService(HireMatchDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
            StripeConfiguration.ApiKey = _configuration["Stripe:SecretKey"];
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentForPremiumAsync(int userId)
        {
            var user = await _context.Set<MyAppUser>().FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                throw new BusinessException("Korisnik nije pronađen.");

            if (user.IsPremium)
                throw new BusinessException("Već imate Premium članstvo.");

            var pendingPayment = await _context.PremiumPayments
                .AnyAsync(p => p.UserId == userId && p.Status == "pending" && !p.IsRefunded);
            if (pendingPayment)
                throw new BusinessException("Već postoji otvorena uplata. Molimo pričekajte ili kontaktirajte podršku.");

            decimal totalAmount = 15.00m;

            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(totalAmount * 100),
                Currency = "usd",
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions { Enabled = true },
                Metadata = new Dictionary<string, string> { { "userId", user.Id.ToString() } }
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            var payment = new PremiumPayment
            {
                UserId = userId,
                PaymentIntentId = paymentIntent.Id,
                WebhookEventId = null,
                Amount = totalAmount,
                Currency = "usd",
                Status = "pending",
                CreatedAt = DateTime.UtcNow
            };
            _context.PremiumPayments.Add(payment);

            user.LastPaymentIntentId = paymentIntent.Id;
            await _context.SaveChangesAsync();

            return new PaymentIntentResponse
            {
                ClientSecret = paymentIntent.ClientSecret,
                PaymentIntentId = paymentIntent.Id,
                UserId = user.Id,
                TotalAmount = totalAmount
            };
        }

        public async Task RefundPremiumAsync(int userId)
        {
            var user = await _context.Set<MyAppUser>().FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                throw new BusinessException("Korisnik nije pronađen.");

            if (!user.IsPremium || string.IsNullOrEmpty(user.LastPaymentIntentId))
                throw new BusinessException("Nema aktivne Premium uplate za povrat.");

            var payment = await _context.PremiumPayments
                .FirstOrDefaultAsync(p => p.PaymentIntentId == user.LastPaymentIntentId && !p.IsRefunded);
            if (payment == null)
                throw new BusinessException("Nije pronađena lokalna evidencija uplate za povrat.");

            var refundService = new RefundService();
            await refundService.CreateAsync(new RefundCreateOptions
            {
                PaymentIntent = user.LastPaymentIntentId
            });

            payment.IsRefunded = true;
            payment.RefundedAt = DateTime.UtcNow;
            payment.Status = "refunded";

            user.IsPremium = false;
            user.LastPaymentIntentId = null;
            await _context.SaveChangesAsync();
        }
    }
}