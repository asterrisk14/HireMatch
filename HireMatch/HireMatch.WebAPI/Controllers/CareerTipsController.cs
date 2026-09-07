using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HireMatch.WebAPI.Controllers
{
    public class CareerTipsController : BaseCRUDController<CareerTipResponse, CareerTipSearchObject, CareerTipInsertRequest, CareerTipUpdateRequest>
    {
        public CareerTipsController(ICareerTipService service) : base(service) { }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Post([FromBody] CareerTipInsertRequest request)
            => await base.Post(request);

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] CareerTipUpdateRequest request)
            => await base.Put(id, request);
    }
}