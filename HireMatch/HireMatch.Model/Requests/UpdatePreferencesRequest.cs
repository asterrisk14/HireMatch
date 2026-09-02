using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class UpdatePreferencesRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "PreferredIndustryId must be a valid ID.")]
        public int? PreferredIndustryId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "PreferredEmploymentTypeId must be a valid ID.")]
        public int? PreferredEmploymentTypeId { get; set; }
    }
}