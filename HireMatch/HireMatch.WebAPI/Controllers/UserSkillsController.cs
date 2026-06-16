using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using HireMatch.Model.Requests;
using HireMatch.Services.Interfaces; // <-- DODANO

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
        public async Task<IActionResult> Post(UserSkillInsertRequest request)
        {
            var result = await _userSkillService.AddSkillToUserAsync(request);
            if (!result) return BadRequest("Greška pri dodavanju vještine.");
            
            return Ok(new { message = "Vještina uspješno dodana korisniku!" });
        }
    }
}