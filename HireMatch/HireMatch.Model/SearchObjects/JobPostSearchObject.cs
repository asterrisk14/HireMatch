using System;

namespace HireMatch.Model.SearchObjects
{
    public class JobPostSearchObject : BaseSearchObject
    {
        public int? CompanyId { get; set; }
        public int? RecruiterId { get; set; }
        public int? EmploymentTypeId { get; set; }
        public string? Title { get; set; }
        public string? Location { get; set; }
        public DateTime? ExpiryDateFrom { get; set; }
        public DateTime? ExpiryDateTo { get; set; }
        public bool? IsActive { get; set; }
        public string? Keyword { get; set; }
    }
}