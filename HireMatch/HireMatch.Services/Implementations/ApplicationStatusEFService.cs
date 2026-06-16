using System.Linq;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;
using Microsoft.EntityFrameworkCore.Storage;

namespace HireMatch.Services.Implementations
{
    public class ApplicationStatusEFService : BaseEFCRUDService<ApplicationStatusResponse, ApplicationStatus, ApplicationStatusSearchObject, ApplicationStatusInsertRequest, ApplicationStatusUpdateRequest>, IApplicationStatusService
    {
        public ApplicationStatusEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<ApplicationStatus> ApplySearchFilters(IQueryable<ApplicationStatus> query, ApplicationStatusSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search?.Name))
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));

            return query.OrderBy(x => x.Id);
        }
        
    }
}