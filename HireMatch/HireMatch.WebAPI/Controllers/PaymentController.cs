using System.Threading.Tasks;
using System.Security.Claims;
using HireMatch.Services.Interfaces;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        private int? GetUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                      ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;
            return int.TryParse(claim, out var id) ? id : (int?)null;
        }

        [HttpPost("create-intent")]
        public async Task<ActionResult<PaymentIntentResponse>> CreatePaymentIntent()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                var result = await _paymentService.CreatePaymentIntentForPremiumAsync(userId.Value);
                return Ok(result);
            }
            catch (System.ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("refund")]
        public async Task<IActionResult> Refund()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            try
            {
                await _paymentService.RefundPremiumAsync(userId.Value);
                return Ok(new { message = "Refund processed successfully. Premium has been removed." });
            }
            catch (System.Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}