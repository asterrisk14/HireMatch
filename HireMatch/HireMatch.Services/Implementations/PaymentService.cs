using System;
using System.Collections.Generic;
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
        throw new ArgumentException("Korisnik nije pronađen.");

    if (user.IsPremium)
        throw new ArgumentException("Već imate Premium članstvo.");

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

    // Zapamti intent za kasniji refund
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
                throw new ArgumentException("Korisnik nije pronađen.");

            if (!user.IsPremium || string.IsNullOrEmpty(user.LastPaymentIntentId))
                throw new ArgumentException("Nema aktivne Premium uplate za povrat.");

            // Stvarni refund preko Stripe (na osnovu stvarno naplaćenog PaymentIntent-a)
            var refundService = new RefundService();
            await refundService.CreateAsync(new RefundCreateOptions
            {
                PaymentIntent = user.LastPaymentIntentId
            });

            user.IsPremium = false;
            user.LastPaymentIntentId = null;
            await _context.SaveChangesAsync();
        }
    }
}