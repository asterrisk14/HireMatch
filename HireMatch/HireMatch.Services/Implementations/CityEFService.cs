using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;

namespace HireMatch.Services.Implementations
{
    public class CityEFService : BaseEFCRUDService<CityResponse, City, CitySearchObject, CityInsertRequest, CityUpdateRequest>, ICityService
    {
        public CityEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<City> ApplySearchFilters(IQueryable<City> query, CitySearchObject search)
        {
            query = query.Include(x => x.Country);

            if (search?.CountryId != null)
                query = query.Where(x => x.CountryId == search.CountryId.Value);

            return query.OrderBy(x => x.Name);
        }

        protected override CityResponse MapToResponse(City entity)
        {
            return new CityResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                CountryId = entity.CountryId,
                CountryName = entity.Country?.Name ?? string.Empty,
            };
        }
    }
}