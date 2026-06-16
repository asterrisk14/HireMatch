namespace HireMatch.Model.SearchObjects
{
    public class CandidateSearchObject : BaseSearchObject
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? CurrentTitle { get; set; }
        public string? Keyword { get; set; }
        public bool? HasApplications { get; set; }
    }
}