using System;
using System.Collections.Generic;

namespace HireMatch.Services.Database
{
    public class Company
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public string Address { get; set; } = default!;

        public int? CityId { get; set; }
        public City? City { get; set; }

        public string RegistrationNumber { get; set; } = default!;
        public string? Description { get; set; }
        public string? Website { get; set; }
        public string? LogoUrl { get; set; }
        public DateTime CreatedAt { get; set; }

        public ICollection<JobPost> JobPosts { get; set; } = new List<JobPost>();
    }
}