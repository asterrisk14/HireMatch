using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Services.Implementations;

namespace HireMatch.Services.Implementations
{
    public class WorkModeEFService : BaseEFReadService<WorkModeResponse, WorkMode, BaseSearchObject>, IWorkModeService
    {
        public WorkModeEFService(HireMatchDbContext context) : base(context) { }
    }
}