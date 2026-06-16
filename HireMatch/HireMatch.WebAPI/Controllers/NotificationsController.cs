using System.Security.Claims;
using System.Threading.Tasks;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _service;

        public NotificationsController(INotificationService service)
        {
            _service = service;
        }

        private int? GetUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                      ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;
            return int.TryParse(claim, out var id) ? id : (int?)null;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] NotificationSearchObject search)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();
            var result = await _service.GetForUser(userId.Value, search);
            return Ok(result);
        }

        [HttpGet("unread-count")]
        public async Task<IActionResult> GetUnreadCount()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();
            var count = await _service.GetUnreadCount(userId.Value);
            return Ok(new { count });
        }

        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();
            await _service.MarkAsRead(userId.Value, id);
            return Ok();
        }

        [HttpPut("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();
            await _service.MarkAllAsRead(userId.Value);
            return Ok();
        }
    }
}