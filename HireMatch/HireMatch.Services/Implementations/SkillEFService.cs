using System.Linq;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;

namespace HireMatch.Services.Implementations
{
    public class SkillEFService : BaseEFCRUDService<SkillResponse, Skill, SkillSearchObject, SkillInsertRequest, SkillUpdateRequest>, ISkillService
    {
        public SkillEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<Skill> ApplySearchFilters(IQueryable<Skill> query, SkillSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search?.Name))
                query = query.Where(x => x.Name.ToLower().Contains(search.Name.ToLower()));

            return query.OrderBy(x => x.Name);
        }
    }
}