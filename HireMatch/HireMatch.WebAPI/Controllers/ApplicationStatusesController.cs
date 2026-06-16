using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;

namespace HireMatch.WebAPI.Controllers
{
    public class ApplicationStatusesController : BaseCRUDController<ApplicationStatusResponse, ApplicationStatusSearchObject, ApplicationStatusInsertRequest, ApplicationStatusUpdateRequest>
    {
        public ApplicationStatusesController(IApplicationStatusService service) : base(service) { }
    }
}