using System;
using Microsoft.AspNetCore.Http;
namespace HireMatch.Model.Responses
{
    public class ApplicationResponse
    {
        public int Id { get; set; }
        public int CandidateId { get; set; }
        public string CandidateFirstName { get; set; } = default!;
        public string CandidateLastName { get; set; } = default!;
        public string CandidateEmail { get; set; } = default!;
        public int JobPostId { get; set; }
        public string JobPostTitle { get; set; } = default!;
        public int ApplicationStatusId { get; set; }
        public string ApplicationStatusName { get; set; } = default!;
        public DateTime AppliedAt { get; set; }
        public string CompanyName { get; set; } = default!;
        public string CompanyLogoUrl { get; set; } = string.Empty;
        public string CvUrl { get; set; } = string.Empty;
    }
}