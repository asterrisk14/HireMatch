using System;

namespace HireMatch.Model.Responses
{
    public class FavouriteResponse
    {
        public int Id { get; set; }
        public int CandidateId { get; set; }
        public int JobPostId { get; set; }
        public string JobPostTitle { get; set; } = default!;
        public string CompanyName { get; set; } = default!;
        public string CompanyLogoUrl { get; set; } = string.Empty;
        public string Location { get; set; } = default!;
        public string EmploymentTypeName { get; set; } = default!;
        public DateTime ExpiryDate { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}