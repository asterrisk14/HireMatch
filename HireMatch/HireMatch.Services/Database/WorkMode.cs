using System.Collections.Generic;

namespace HireMatch.Services.Database
{
    public class WorkMode
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!; // Remote, Hybrid, On-site
        public ICollection<JobPost> JobPosts { get; set; } = new List<JobPost>();
    }
}