using Microsoft.AspNetCore.Mvc;
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
    }
}
