namespace HireMatch.Services.Database{
    public class CandidatePreference
    {
        public int Id { get; set; }

        public int CandidateId { get; set; }
        public MyAppUser Candidate { get; set; } = null!;

        public int? IndustryId { get; set; }
        public Industry? Industry { get; set; }

        public int? SkillId { get; set; }
        public Skill? Skill { get; set; }

        public int? EmploymentTypeId { get; set; }
        public EmploymentType? EmploymentType { get; set; }

    }
}
