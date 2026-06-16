using System;

namespace HireMatch.Model.Requests
{
    public class CandidateUpdateRequest
    {
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string Phone { get; set; } = default!;
        public int? CountryId { get; set; }
        public int? CityId { get; set; }
        public string CurrentTitle { get; set; } = default!;
        public int YearsOfExperience { get; set; }
        public string Summary { get; set; } = default!;
        public string[] Skills { get; set; } = Array.Empty<string>();
        public string LinkedInUrl { get; set; } = default!;
        public string PortfolioUrl { get; set; } = default!;
    }
}