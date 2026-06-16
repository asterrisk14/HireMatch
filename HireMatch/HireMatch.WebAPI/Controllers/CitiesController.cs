using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;

namespace HireMatch.WebAPI.Controllers
{
    public class CitiesController : BaseCRUDController<CityResponse, CitySearchObject, CityInsertRequest, CityUpdateRequest>
    {
        public CitiesController(ICityService service) : base(service) { }
    }
}