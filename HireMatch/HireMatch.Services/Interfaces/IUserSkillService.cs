using System.Threading.Tasks;
using HireMatch.Model.Requests;

namespace HireMatch.Services.Interfaces
{
    public interface IUserSkillService
    {
        Task<bool> AddSkillToUserAsync(UserSkillInsertRequest request);
    }
}