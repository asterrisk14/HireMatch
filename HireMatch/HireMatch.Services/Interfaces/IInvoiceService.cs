namespace HireMatch.Services.Interfaces
{
    public interface IInvoiceService
    {
        Task HandlePaymentIntentSucceededAsync(string paymentIntentId);
    }
}

