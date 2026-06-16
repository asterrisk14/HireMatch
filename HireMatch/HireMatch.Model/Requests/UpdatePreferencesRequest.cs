namespace HireMatch.Model.Requests
{
    public class UpdatePreferencesRequest
    {
        public int? PreferredIndustryId { get; set; }
        public int? PreferredEmploymentTypeId { get; set; }
    }
}