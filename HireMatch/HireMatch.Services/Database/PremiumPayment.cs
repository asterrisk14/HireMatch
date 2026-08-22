using System;

namespace HireMatch.Services.Database
{
    public class PremiumPayment
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public MyAppUser User { get; set; } = default!;
        public string PaymentIntentId { get; set; } = default!;
        public string WebhookEventId { get; set; } = default!;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "usd";
        public string Status { get; set; } = "pending";
        public DateTime CreatedAt { get; set; }
        public DateTime? ConfirmedAt { get; set; }
        public bool IsRefunded { get; set; } = false;
        public DateTime? RefundedAt { get; set; }
    }
}