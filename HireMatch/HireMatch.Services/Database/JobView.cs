using System;

namespace HireMatch.Services.Database
{
    public class JobView
    {
        public int Id { get; set; }
        public int JobPostId { get; set; }
        public JobPost JobPost { get; set; } = default!;

        public int CandidateId { get; set; }
        public MyAppUser Candidate { get; set; } = default!;

        public DateTime ViewedAt { get; set; }
    }
}
