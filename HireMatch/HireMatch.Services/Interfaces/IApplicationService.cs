using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Model.Result;

namespace HireMatch.Services.Interfaces
{
    public interface IApplicationService : IBaseCRUDService<ApplicationResponse, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest>
    {
    }
}