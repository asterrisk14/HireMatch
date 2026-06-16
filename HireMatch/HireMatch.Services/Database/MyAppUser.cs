using System;
using System.Collections.Generic;

namespace HireMatch.Services.Database
{
    public class MyAppUser
    {
        public int Id { get; set; }
        public string Email { get; set; } = default!;
        public string PasswordHash { get; set; } = string.Empty;
        public string FirstName { get; set; } = default!;
        public string LastName { get; set; } = default!;
        public string Role { get; set; } = "Candidate";
        public string Phone { get; set; } = default!;
        public DateOnly DateOfBirth { get; set; }
        public bool IsPremium { get; set; } = false;
        public int? CityId { get; set; }
        public City? City { get; set; }

        public int? CountryId { get; set; }
        public Country? Country { get; set; }
        public string? LastPaymentIntentId { get; set; }
        public ICollection<UserSkill> UserSkills { get; set; } = new List<UserSkill>();

        public Candidate? CandidateProfile { get; set; }
    }    
}