
namespace HireMatch.Services.Database
{
    public class JobPostSkill
    {
        public int JobPostId { get; set; }
        public JobPost JobPost { get; set; } = default!;

        public int SkillId { get; set; }
        public Skill Skill { get; set; } = default!;
    }
}
