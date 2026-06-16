using System.Linq;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;

namespace HireMatch.Services.Implementations
{
    public class IndustryEFService : BaseEFCRUDService<IndustryResponse, Industry, IndustrySearchObject, IndustryInsertRequest, IndustryUpdateRequest>, IIndustryService
    {
        public IndustryEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<Industry> ApplySearchFilters(IQueryable<Industry> query, IndustrySearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search?.Name))
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));

            return query.OrderBy(x => x.Name);
        }
    }
}