using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class JobPostUpdateRequest : IValidatableObject
    {
        [Range(1, int.MaxValue, ErrorMessage = "CompanyId must be a valid ID.")]
        public int CompanyId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "RecruiterId must be a valid ID.")]
        public int RecruiterId { get; set; }
        [Required(ErrorMessage = "Title is required.")]
        [StringLength(200, MinimumLength = 2, ErrorMessage = "Title must be between 2 and 200 characters.")]
        public string Title { get; set; } = default!;
        [Required(ErrorMessage = "Description is required.")]
        [StringLength(5000, MinimumLength = 10, ErrorMessage = "Description must be between 10 and 5000 characters.")]
        public string Description { get; set; } = default!;
        [Required(ErrorMessage = "Compensation is required.")]
        [StringLength(200, MinimumLength = 1, ErrorMessage = "Compensation must be between 1 and 200 characters.")]
        public string Compensation { get; set; } = default!;
        public int? CityId { get; set; }
        public int? WorkModeId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "EmploymentTypeId must be a valid ID.")]
        public int EmploymentTypeId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "IndustryId must be a valid ID.")]
        public int IndustryId { get; set; }
        public DateTime ExpiryDate { get; set; }
        public List<int> SkillIds { get; set; } = new List<int>();

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (ExpiryDate <= DateTime.UtcNow)
                yield return new ValidationResult("ExpiryDate must be in the future.", new[] { nameof(ExpiryDate) });
        }
    }
}