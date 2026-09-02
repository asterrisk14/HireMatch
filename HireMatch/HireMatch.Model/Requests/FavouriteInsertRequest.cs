using System.ComponentModel.DataAnnotations;

namespace HireMatch.Model.Requests
{
    public class FavouriteInsertRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "CandidateId must be a valid ID.")]
        public int CandidateId { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "JobPostId must be a valid ID.")]
        public int JobPostId { get; set; }
    }
}
