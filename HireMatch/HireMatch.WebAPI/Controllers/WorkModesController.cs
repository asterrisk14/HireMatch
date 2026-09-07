using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using HireMatch.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace HireMatch.WebAPI.Controllers
{
public class WorkModesController : BaseCRUDController<WorkModeResponse, BaseSearchObject, WorkModeInsertRequest, WorkModeUpdateRequest>
    {
        public WorkModesController(IWorkModeService service) : base(service) { }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Post([FromBody] WorkModeInsertRequest request)
            => await base.Post(request);

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] WorkModeUpdateRequest request)
            => await base.Put(id, request);
    }
}