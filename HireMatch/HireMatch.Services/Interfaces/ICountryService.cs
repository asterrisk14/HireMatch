using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;

namespace HireMatch.Services.Interfaces
{
    public interface ICountryService : IBaseCRUDService<CountryResponse, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>
    {
    }
}