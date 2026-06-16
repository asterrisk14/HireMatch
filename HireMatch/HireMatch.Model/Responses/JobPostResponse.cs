using System;

namespace HireMatch.Model.Responses
{
    public class JobPostResponse
    {
        public int Id { get; set; }
        public int CompanyId { get; set; }
        public string CompanyName { get; set; } = default!;
        public string CompanyLogoUrl { get; set; } = string.Empty;
        public int RecruiterId { get; set; }
        public string Title { get; set; } = default!;
        public string Description { get; set; } = default!;
        public string Compensation { get; set; } = default!;
        public int EmploymentTypeId { get; set; }
        public string EmploymentTypeName { get; set; } = default!;
        public bool IsPaid { get; set; }

        public string Location { get; set; } = string.Empty;
        public int? CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public int? WorkModeId { get; set; }
        public string WorkModeName { get; set; } = string.Empty;

        public DateTime ExpiryDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int? IndustryId { get; set; }
        public string IndustryName { get; set; } = string.Empty;
        public int ApplicationCount { get; set; }
    }
}