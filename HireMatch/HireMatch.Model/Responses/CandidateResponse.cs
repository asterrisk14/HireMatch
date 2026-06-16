using System;

namespace HireMatch.Model.Responses
{
    public class CandidateResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string Phone { get; set; } = default!;
        public int? CountryId { get; set; }
        public string CountryName { get; set; } = string.Empty;
        public int? CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public string CurrentTitle { get; set; } = default!;
        public int YearsOfExperience { get; set; }
        public string Summary { get; set; } = default!;
        public string[] Skills { get; set; } = Array.Empty<string>();
        public string LinkedInUrl { get; set; } = default!;
        public string PortfolioUrl { get; set; } = default!;
        public string CvUrl { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
        public bool IsPremium { get; set; }
        public int? PreferredIndustryId { get; set; }
        public string PreferredIndustryName { get; set; } = string.Empty;
        public int? PreferredEmploymentTypeId { get; set; }
        public string PreferredEmploymentTypeName { get; set; } = string.Empty;
    }
}