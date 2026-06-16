using System.Threading.Tasks;
using HireMatch.Model.Responses;

namespace HireMatch.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<PaymentIntentResponse> CreatePaymentIntentForPremiumAsync(int userId);
        Task RefundPremiumAsync(int userId);
    }
}