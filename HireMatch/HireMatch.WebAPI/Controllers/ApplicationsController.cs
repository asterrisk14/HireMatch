using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ApplicationsController : BaseCRUDController<ApplicationResponse, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest>
    {
        public ApplicationsController(IApplicationService service) : base(service) { }

        [HttpPost("upload")]
        [Authorize]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadApplication([FromForm] int jobPostId, IFormFile? cvFile)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                                ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var candidateId))
                return Unauthorized();

            if (cvFile == null || cvFile.Length == 0)
                return BadRequest("CV file is required.");

            var allowedExtensions = new[] { ".pdf", ".doc", ".docx" };
            var ext = Path.GetExtension(cvFile.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(ext))
                return BadRequest("Only PDF and Word documents are allowed.");

            if (cvFile.Length > 5 * 1024 * 1024)
                return BadRequest("File size must be under 5MB.");

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "cvs");
            Directory.CreateDirectory(uploadsFolder);
            var fileName = $"{Guid.NewGuid()}{ext}";
            var filePath = Path.Combine(uploadsFolder, fileName);
            using var stream = new FileStream(filePath, FileMode.Create);
            await cvFile.CopyToAsync(stream);
            var cvUrl = $"/cvs/{fileName}";

            var request = new ApplicationInsertRequest
            {
                CandidateId = candidateId,
                JobPostId = jobPostId,
                ApplicationStatusId = 1,
                CvUrl = cvUrl
            };

            var result = await _crudService.Insert(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] ApplicationUpdateRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(userIdClaim, out var userId))
                request.ChangedById = userId;

            var result = await _crudService.Update(id, request);
            return Ok(result);
        }
    }
}