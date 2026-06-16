namespace HireMatch.Model.SearchObjects
{
    public class ApplicationSearchObject : BaseSearchObject
    {
        public int? CandidateId { get; set; }
        public int? JobPostId { get; set; }
        public int? ApplicationStatusId { get; set; }
    }
}