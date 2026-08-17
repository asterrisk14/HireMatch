using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using HireMatch.Model.Requests;
using Microsoft.EntityFrameworkCore;
using HireMatch.Services;
namespace HireMatch.Services.Implementations
{
public class WorkModeEFService : BaseEFCRUDService<WorkModeResponse, WorkMode, BaseSearchObject, WorkModeInsertRequest, WorkModeUpdateRequest>, IWorkModeService   {
        public WorkModeEFService(HireMatchDbContext context) : base(context) { }   
         }
}