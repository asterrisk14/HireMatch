using System;
using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class CandidateUpdateRequest
    {
        [Required(ErrorMessage = "FirstName is required.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "FirstName must be between 2 and 50 characters.")]
        public string FirstName { get; set; } = default!;

        [Required(ErrorMessage = "LastName is required.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "LastName must be between 2 and 50 characters.")]
        public string LastName { get; set; } = default!;

        [Required(ErrorMessage = "Email is required.")]
        [StringLength(254, MinimumLength = 5, ErrorMessage = "Email must be between 5 and 254 characters.")]
        [EmailAddress(ErrorMessage = "Invalid email format.")]
        public string Email { get; set; } = default!;

        [Required(ErrorMessage = "Phone is required.")]
        [StringLength(20, MinimumLength = 7, ErrorMessage = "Phone must be between 7 and 20 characters.")]
        [Phone(ErrorMessage = "Invalid phone format.")]
        public string Phone { get; set; } = default!;

        public int? CountryId { get; set; }
        public int? CityId { get; set; }

        [Required(ErrorMessage = "CurrentTitle is required.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "CurrentTitle must be between 2 and 100 characters.")]
        public string CurrentTitle { get; set; } = default!;

        [Range(0, 50, ErrorMessage = "Years of experience must be between 0 and 50.")]
        public int YearsOfExperience { get; set; }

        [StringLength(2000, ErrorMessage = "Summary must be under 2000 characters.")]
        public string? Summary { get; set; }

        public string[] Skills { get; set; } = Array.Empty<string>();

        [StringLength(500, ErrorMessage = "LinkedInUrl must be under 500 characters.")]
        [Url(ErrorMessage = "Invalid URL format.")]
        public string? LinkedInUrl { get; set; }

        [StringLength(500, ErrorMessage = "PortfolioUrl must be under 500 characters.")]
        [Url(ErrorMessage = "Invalid URL format.")]
        public string? PortfolioUrl { get; set; }
    }
}