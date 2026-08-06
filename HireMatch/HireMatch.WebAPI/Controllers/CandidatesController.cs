using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Services;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using System.Security.Claims;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CandidatesController : BaseCRUDController<CandidateResponse, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest>
    {
        private readonly ICandidateService _candidateService;
        private readonly INotificationService _notificationService;
        private readonly HireMatch.Services.Messaging.IMessagePublisher _publisher;

        public CandidatesController(
            ICandidateService service,
            INotificationService notificationService,
            HireMatch.Services.Messaging.IMessagePublisher publisher) : base(service)
        {
            _candidateService = service;
            _notificationService = notificationService;
            _publisher = publisher;
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Post([FromBody] CandidateInsertRequest request)
        {
            return await base.Post(request);
        }

        [HttpPut("{id}")]
        [Authorize]
        public override async Task<IActionResult> Put(int id, [FromBody] CandidateUpdateRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && userId != id)
                return Forbid();

            var result = await _crudService.Update(id, request);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            await _crudService.Delete(id);
            return NoContent();
        }

        [HttpPut("{id}/picture")]
        [Authorize]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadPicture(int id, IFormFile? pictureFile)
        {
            if (pictureFile == null || pictureFile.Length == 0)
                return BadRequest("No file uploaded.");

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && userId != id)
                return Forbid();

            var result = await _candidateService.UpdateProfilePicture(id, pictureFile);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPut("{id}/cv")]
        [Authorize]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadCv(int id, IFormFile? cvFile)
        {
            if (cvFile == null || cvFile.Length == 0)
                return BadRequest("No file uploaded.");

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin && userId != id)
                return Forbid();

            var result = await _candidateService.UpdateCv(id, cvFile);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPut("{id}/preferences")]
        [Authorize]
        public async Task<IActionResult> UpdatePreferences(int id, [FromBody] UpdatePreferencesRequest request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            if (userId != id)
                return Forbid();

            var result = await _candidateService.UpdatePreferences(id, request);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPost("{id}/contact")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ContactCandidate(int id)
        {
            var candidate = await _candidateService.GetById(id);
            if (candidate == null) return NotFound();

            await _notificationService.CreateNotification(
                id,
                "RecruiterContact",
                "A recruiter from HireMatch is interested in your profile and may reach out soon.");

            if (!string.IsNullOrEmpty(candidate.Email))
            {
                await _publisher.PublishEmail(new HireMatch.Services.Messaging.EmailMessage
                {
                    ToEmail = candidate.Email,
                    Subject = "A recruiter is interested in your profile",
                    Body = $"Hello {candidate.FirstName},\n\nA recruiter from HireMatch is interested in your profile and may reach out soon.\n\nHireMatch"
                });
            }

            return Ok(new { message = "Candidate contacted." });
        }
    }
}