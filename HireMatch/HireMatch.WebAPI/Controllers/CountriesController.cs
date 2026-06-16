using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;

namespace HireMatch.WebAPI.Controllers
{
    public class CountriesController : BaseCRUDController<CountryResponse, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>
    {
        public CountriesController(ICountryService service) : base(service) { }
    }
}