using System.Threading.Tasks;
using HireMatch.Model.Result;
using HireMatch.Model.SearchObjects;

namespace HireMatch.Services.Interfaces
{
    public interface IBaseReadService<TResponse, TSearch>
        where TResponse : class
        where TSearch : BaseSearchObject
    {
        Task<PagedResult<TResponse>> Get(TSearch search);
        Task<TResponse?> GetById(int id);
    }
}