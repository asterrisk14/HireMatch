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

        public int ApplicationStatusId { get; set; } // FK na application_status
        public ApplicationStatus ApplicationStatus { get; set; } = default!;

        public DateTime AppliedAt { get; set; }
        public string CvUrl { get; set; } = default!;
    }
}
