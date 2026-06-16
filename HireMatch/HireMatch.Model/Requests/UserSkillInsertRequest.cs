namespace HireMatch.Model.Requests
{
    public class UserSkillInsertRequest
    {
        public int UserId { get; set; }
        public string SkillName { get; set; } = default!;
    }
}