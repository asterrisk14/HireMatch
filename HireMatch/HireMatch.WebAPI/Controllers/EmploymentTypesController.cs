using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;

namespace HireMatch.WebAPI.Controllers
{
    public class EmploymentTypesController : BaseCRUDController<EmploymentTypeResponse, EmploymentTypeSearchObject, EmploymentTypeInsertRequest, EmploymentTypeUpdateRequest>
    {
        public EmploymentTypesController(IEmploymentTypeService service) : base(service) { }
    }
}