using System;

namespace HireMatch.Services.Database
{
    public class UserActivityLog
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public MyAppUser User { get; set; } = default!;

        public string Action { get; set; } = default!; // applied, viewed_profile, saved_job
        public string TargetType { get; set; } = default!; // job_post, candidate
        public int TargetId { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
