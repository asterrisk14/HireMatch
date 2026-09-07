using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HireMatch.WebAPI.Controllers
{
    public class EmploymentTypesController : BaseCRUDController<EmploymentTypeResponse, EmploymentTypeSearchObject, EmploymentTypeInsertRequest, EmploymentTypeUpdateRequest>
    {
        public EmploymentTypesController(IEmploymentTypeService service) : base(service) { }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Post([FromBody] EmploymentTypeInsertRequest request)
            => await base.Post(request);

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] EmploymentTypeUpdateRequest request)
            => await base.Put(id, request);
    }
}