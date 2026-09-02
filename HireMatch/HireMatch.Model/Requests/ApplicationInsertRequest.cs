using Microsoft.AspNetCore.Http;

using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class ApplicationInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "CandidateId must be a valid ID.")]
        public int CandidateId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "JobPostId must be a valid ID.")]
        public int JobPostId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "ApplicationStatusId must be a valid ID.")]
        public int ApplicationStatusId { get; set; }
        [StringLength(500, MinimumLength = 1, ErrorMessage = "CvUrl must be between 1 and 500 characters.")]
        public string CvUrl { get; set; } = string.Empty;

    }
}