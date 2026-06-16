using System;

namespace HireMatch.Model.Responses
{
    public class RecommendedJobResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = default!;
        public string CompanyName { get; set; } = string.Empty;
        public string CompanyLogoUrl { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string EmploymentTypeName { get; set; } = string.Empty;
        public DateTime ExpiryDate { get; set; }
        public int Score { get; set; }
        public string Explanation { get; set; } = string.Empty;
    }
}