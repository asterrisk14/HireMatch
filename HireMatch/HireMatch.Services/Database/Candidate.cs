namespace HireMatch.Services.Database
{
    public class Candidate
    {
        public int Id { get; set; }
        public string? CvUrl { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public string CurrentTitle { get; set; } = default!;
        public string? Summary { get; set; }
        public int YearsOfExperience { get; set; }
        public string? LinkedInUrl { get; set; }
        public string? PortfolioUrl { get; set; }

        public int? CityId { get; set; }
        public City? City { get; set; }
        public int? CountryId { get; set; }
        public Country? Country { get; set; }

        // Preferencije za sistem preporuke
        public int? PreferredIndustryId { get; set; }
        public Industry? PreferredIndustry { get; set; }
        public int? PreferredEmploymentTypeId { get; set; }
        public EmploymentType? PreferredEmploymentType { get; set; }

        public int MyAppUserId { get; set; }
        public MyAppUser MyAppUser { get; set; } = default!;
    }
}