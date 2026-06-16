using System;
using System.Collections.Generic;

namespace HireMatch.Model.Requests
{
    public class JobPostInsertRequest
    {
        public int CompanyId { get; set; }
        public int RecruiterId { get; set; }
        public string Title { get; set; } = default!;
        public string Description { get; set; } = default!;
        public int? CityId { get; set; }
        public int? WorkModeId { get; set; }
        public string Compensation { get; set; } = default!;
        public int EmploymentTypeId { get; set; }
        public int IndustryId { get; set; }
        public DateTime ExpiryDate { get; set; }
        public List<int> SkillIds { get; set; } = new List<int>();
    }
}