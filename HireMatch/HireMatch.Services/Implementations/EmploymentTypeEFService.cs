using System.Linq;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;

namespace HireMatch.Services.Implementations
{
    public class EmploymentTypeEFService : BaseEFCRUDService<EmploymentTypeResponse, EmploymentType, EmploymentTypeSearchObject, EmploymentTypeInsertRequest, EmploymentTypeUpdateRequest>, IEmploymentTypeService
    {
        public EmploymentTypeEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<EmploymentType> ApplySearchFilters(IQueryable<EmploymentType> query, EmploymentTypeSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search?.Name))
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));

            return query.OrderBy(x => x.Name);
        }
    }
}