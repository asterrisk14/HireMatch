namespace HireMatch.Model.Requests
{
    public class ApplicationUpdateRequest
    {
        public int ApplicationStatusId { get; set; }
        public string? RejectionReason { get; set; }
        public int? ChangedById { get; set; }
    }
}