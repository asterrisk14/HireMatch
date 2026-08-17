using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Model.Requests;

namespace HireMatch.Services.Interfaces
{
    public interface IWorkModeService : IBaseCRUDService<WorkModeResponse, BaseSearchObject, WorkModeInsertRequest, WorkModeUpdateRequest> { }
}