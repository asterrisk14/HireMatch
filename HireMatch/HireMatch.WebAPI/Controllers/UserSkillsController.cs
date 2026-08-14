using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using HireMatch.Model.Requests;
using HireMatch.Services.Interfaces; 
using Microsoft.AspNetCore.Authorization;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserSkillsController : ControllerBase
    {
        private readonly IUserSkillService _userSkillService;

        public UserSkillsController(IUserSkillService userSkillService)
        {
            _userSkillService = userSkillService;
        }

        
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Post(UserSkillInsertRequest request)
        {
            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            request.UserId = userId;

            var result = await _userSkillService.AddSkillToUserAsync(request);
            if (!result) return BadRequest("Error while adding the skill.");
            return Ok(new { message = "Skill successfully added to the user!" });
        }
    }
}