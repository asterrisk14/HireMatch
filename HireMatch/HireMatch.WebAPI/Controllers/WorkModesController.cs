using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;

namespace HireMatch.WebAPI.Controllers
{
    public class WorkModesController : BaseController<WorkModeResponse, BaseSearchObject>
    {
        public WorkModesController(IWorkModeService service) : base(service) { }
    }
}