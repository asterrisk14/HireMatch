using System.Collections.Generic;
using System.Threading.Tasks;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;

namespace HireMatch.Services.Interfaces
{
    public interface IJobPostService : IBaseCRUDService<JobPostResponse, JobPostSearchObject, JobPostInsertRequest, JobPostUpdateRequest>
    {
        Task<List<RecommendedJobResponse>> GetRecommended(int candidateId, int take = 10);
    }
}