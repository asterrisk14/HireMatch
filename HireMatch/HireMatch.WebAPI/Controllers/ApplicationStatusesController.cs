using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HireMatch.WebAPI.Controllers
{
    public class ApplicationStatusesController : BaseCRUDController<ApplicationStatusResponse, ApplicationStatusSearchObject, ApplicationStatusInsertRequest, ApplicationStatusUpdateRequest>
    {
        public ApplicationStatusesController(IApplicationStatusService service) : base(service) { }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Post([FromBody] ApplicationStatusInsertRequest request)
            => await base.Post(request);

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] ApplicationStatusUpdateRequest request)
            => await base.Put(id, request);
    }
}