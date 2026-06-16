using System;

namespace HireMatch.Services.Database
{
    public class Favourite
    {
        public int Id { get; set; }
        public int CandidateId { get; set; }
        public MyAppUser Candidate { get; set; } = default!;

        public int JobPostId { get; set; }
        public JobPost JobPost { get; set; } = default!;

        public DateTime CreatedAt { get; set; }
    }
}
