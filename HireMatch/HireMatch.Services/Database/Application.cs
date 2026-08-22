using System;

namespace HireMatch.Services.Database
{
    public class Application
    {
        public int Id { get; set; }

        public int CandidateId { get; set; }
        public MyAppUser Candidate { get; set; } = default!;

        public int JobPostId { get; set; }
        public JobPost JobPost { get; set; } = default!;

        public int ApplicationStatusId { get; set; }
        public ApplicationStatus ApplicationStatus { get; set; } = default!;

        public DateTime AppliedAt { get; set; }
        public string CvUrl { get; set; } = default!;

        public string? RejectionReason { get; set; }
        public DateTime? StatusChangedAt { get; set; }
        public int? StatusChangedById { get; set; }
        public MyAppUser? StatusChangedBy { get; set; }
    }
}