using System.Linq;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;

namespace HireMatch.Services.Implementations
{
    public class CountryEFService : BaseEFCRUDService<CountryResponse, Country, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>, ICountryService
    {
        public CountryEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<Country> ApplySearchFilters(IQueryable<Country> query, CountrySearchObject search)
        {
            return query.OrderBy(x => x.Name);
        }
    }
}