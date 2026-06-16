using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;

namespace HireMatch.Services.Interfaces
{
    public interface ISkillService : IBaseCRUDService<SkillResponse, SkillSearchObject, SkillInsertRequest, SkillUpdateRequest>
    {
    }
}