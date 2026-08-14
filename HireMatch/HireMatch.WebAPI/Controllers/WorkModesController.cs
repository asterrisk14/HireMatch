using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using HireMatch.Model.Requests;
namespace HireMatch.WebAPI.Controllers
{
public class WorkModesController : BaseCRUDController<WorkModeResponse, BaseSearchObject, WorkModeInsertRequest, WorkModeUpdateRequest>
    {
        public WorkModesController(IWorkModeService service) : base(service) { }
    }
}