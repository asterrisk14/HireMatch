using Microsoft.AspNetCore.Http;

namespace HireMatch.Model.Requests
{
    public class ApplicationInsertRequest
    {
        public int CandidateId { get; set; }
        public int JobPostId { get; set; }
        public int ApplicationStatusId { get; set; }
        public string CvUrl { get; set; } = string.Empty;

    }
}