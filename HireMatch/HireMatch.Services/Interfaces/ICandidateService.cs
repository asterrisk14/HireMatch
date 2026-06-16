using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Http;
namespace HireMatch.Services
{
    public interface ICandidateService : IBaseCRUDService<CandidateResponse, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest>
    {
            Task<CandidateResponse?> UpdateProfilePicture(int id, IFormFile file);
            Task<CandidateResponse?> UpdateCv(int id, IFormFile file);
            Task<CandidateResponse?> UpdatePreferences(int id, UpdatePreferencesRequest request);
    }
}