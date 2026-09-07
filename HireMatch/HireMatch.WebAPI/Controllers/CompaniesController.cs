using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services;

namespace HireMatch.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CompaniesController : BaseCRUDController<CompanyResponse, CompanySearchObject, CompanyInsertRequest, CompanyUpdateRequest>
    {
        public CompaniesController(ICompanyService service) : base(service)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Post([FromBody] CompanyInsertRequest request)
            => await base.Post(request);

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Put(int id, [FromBody] CompanyUpdateRequest request)
            => await base.Put(id, request);
    }
}
