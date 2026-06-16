namespace HireMatch.Model.Responses
{
    public class PaymentIntentResponse
    {
        public string ClientSecret { get; set; } = string.Empty;
        public string PaymentIntentId { get; set; } = string.Empty;
        
        public int UserId { get; set; } 
        
        public decimal TotalAmount { get; set; }
    }
}