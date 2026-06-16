using System;
using System.Collections.Generic;

namespace HireMatch.Services.Database
{
    public class JobPost
    {
        public int Id { get; set; }
        public int CompanyId { get; set; }
        public Company Company { get; set; } = default!;

        public int RecruiterId { get; set; }
        public MyAppUser Recruiter { get; set; } = default!;

        public string Title { get; set; } = default!;
        public string Description { get; set; } = default!;
        public string Compensation { get; set; } = default!;
        public EmploymentType EmploymentType { get; set; } = default!;
        public int EmploymentTypeId { get; set; } // FK na employment_types
        public DateTime ExpiryDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int? IndustryId { get; set; }
        public Industry? Industry { get; set; }
        public bool IsPaid { get; set; } = false;

        public int? CityId { get; set; }
        public City? City { get; set; }

        public int? WorkModeId { get; set; }
        public WorkMode? WorkMode { get; set; }

        // Navigation

        public ICollection<Application> Applications { get; set; } = new List<Application>();
        public ICollection<Favourite> Favourites { get; set; } = new List<Favourite>();
        public ICollection<Message> Messages { get; set; } = new List<Message>();
        public ICollection<JobView> JobViews { get; set; } = new List<JobView>();
        public ICollection<JobPostSkill> JobPostSkills { get; set; } = new List<JobPostSkill>(); // M:N
    }
}
