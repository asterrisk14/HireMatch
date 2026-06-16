using System.Collections.Generic;

namespace HireMatch.Services.Database
{
    public class Skill
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;

        public ICollection<UserSkill> UserSkills { get; set; } = new List<UserSkill>();
        public ICollection<JobPostSkill> JobPostSkills { get; set; } = new List<JobPostSkill>();
    }
}
