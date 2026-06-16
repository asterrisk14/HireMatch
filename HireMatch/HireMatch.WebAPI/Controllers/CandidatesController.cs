using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services;
using HireMatch.Services.Interfaces;

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
     

        [HttpPut("{id}/picture")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadPicture(int id, IFormFile? pictureFile)
        {
            if (pictureFile == null || pictureFile.Length == 0)
                return BadRequest("No file uploaded.");

            var result = await _candidateService.UpdateProfilePicture(id, pictureFile);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPut("{id}/cv")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadCv(int id, IFormFile? cvFile)
        {
            if (cvFile == null || cvFile.Length == 0)
                return BadRequest("No file uploaded.");

            var result = await _candidateService.UpdateCv(id, cvFile);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpPut("{id}/preferences")]
        [Authorize]
        public async Task<IActionResult> UpdatePreferences(int id, [FromBody] UpdatePreferencesRequest request)
        {
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

            // Email kroz RabbitMQ -> Worker
            if (!string.IsNullOrEmpty(candidate.Email))
            {
                _publisher.PublishEmail(new HireMatch.Services.Messaging.EmailMessage
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