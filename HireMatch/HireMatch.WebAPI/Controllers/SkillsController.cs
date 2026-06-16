using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Interfaces;

namespace HireMatch.WebAPI.Controllers
{
    public class SkillsController : BaseCRUDController<SkillResponse, SkillSearchObject, SkillInsertRequest, SkillUpdateRequest>
    {
        public SkillsController(ISkillService service) : base(service) { }
    }
}