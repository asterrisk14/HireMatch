using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HireMatch.WebAPI.Controllers
{
    public class ApplicationsController : BaseCRUDController<ApplicationResponse, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest>
    {
        public ApplicationsController(IApplicationService service) : base(service) { }

        [HttpPost]
        [Authorize]
        [Consumes("multipart/form-data")]
        public new async Task<IActionResult> Post([FromForm] int jobPostId, [FromForm] int applicationStatusId, IFormFile? cvFile)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var candidateId))
                return Unauthorized();

            if (cvFile == null || cvFile.Length == 0)
                return BadRequest("CV file is required.");

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "cvs");
            Directory.CreateDirectory(uploadsFolder);
            var fileName = $"{Guid.NewGuid()}_{cvFile.FileName}";
            var filePath = Path.Combine(uploadsFolder, fileName);
            using var stream = new FileStream(filePath, FileMode.Create);
            await cvFile.CopyToAsync(stream);
            var cvUrl = $"/cvs/{fileName}";

            var request = new ApplicationInsertRequest
            {
                CandidateId = candidateId,
                JobPostId = jobPostId,
                ApplicationStatusId = applicationStatusId,
                CvUrl = cvUrl
            };

            var result = await _crudService.Insert(request);
            return Ok(result);
        }
    }
}