using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ApplicationsController : BaseCRUDController<ApplicationResponse, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest>
    {
        private readonly HireMatchDbContext _context;

        public ApplicationsController(
            IApplicationService service,
            HireMatchDbContext context) : base(service)
        {
            _context = context;
        }

        [HttpGet]
        [Authorize]
        public override async Task<IActionResult> Get([FromQuery] ApplicationSearchObject search)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.NameId)?.Value;

            if (userIdClaim == null || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var isAdmin = User.IsInRole("Admin");
            if (!isAdmin)
                search.CandidateId = userId;

            var result = await _service.Get(search);
            return Ok(result);
        }

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

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "private_uploads", "cvs");
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

        [HttpGet("{id}/cv")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DownloadCv(int id)
        {
            var application = await _context.Applications
                .AsNoTracking()
                .FirstOrDefaultAsync(a => a.Id == id);

            if (application == null || string.IsNullOrWhiteSpace(application.CvUrl))
                return NotFound();

            var fileName = Path.GetFileName(application.CvUrl);
            var privatePath = Path.Combine(
                Directory.GetCurrentDirectory(),
                "private_uploads",
                "cvs",
                fileName);
            var legacyPath = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                "cvs",
                fileName);
            var filePath = System.IO.File.Exists(privatePath) ? privatePath : legacyPath;

            if (!System.IO.File.Exists(filePath))
                return NotFound();

            var contentType = Path.GetExtension(fileName).ToLowerInvariant() switch
            {
                ".pdf" => "application/pdf",
                ".doc" => "application/msword",
                ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                _ => "application/octet-stream"
            };

            return PhysicalFile(filePath, contentType, fileName);
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