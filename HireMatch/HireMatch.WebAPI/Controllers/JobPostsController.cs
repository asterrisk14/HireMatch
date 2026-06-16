using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using System.Security.Claims;
using HireMatch.Services.Interfaces;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class JobPostsController : BaseCRUDController<JobPostResponse, JobPostSearchObject, JobPostInsertRequest, JobPostUpdateRequest>
    {
        private readonly IJobPostService _jobPostService;

        public JobPostsController(IJobPostService service) : base(service)
        {
            _jobPostService = service;
        }

        [HttpGet("recommended")]
        [Authorize]
        public async Task<IActionResult> GetRecommended()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var candidateId))
                return Unauthorized();

            var result = await _jobPostService.GetRecommended(candidateId);
            return Ok(result);
        }
    }
}