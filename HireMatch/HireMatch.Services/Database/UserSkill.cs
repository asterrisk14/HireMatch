using System.ComponentModel.DataAnnotations;

namespace HireMatch.Services.Database
{
    public class UserSkill
    {
        public int UserId { get; set; }
        public MyAppUser User { get; set; } = default!;

        public int SkillId { get; set; }
        public Skill Skill { get; set; } = default!;
    }
}
