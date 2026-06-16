using System.Threading.Tasks;
using HireMatch.Model.SearchObjects;

namespace HireMatch.Services.Interfaces
{
    public interface IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate> : IBaseReadService<TResponse, TSearch>
        where TResponse : class
        where TSearch : BaseSearchObject
        where TInsert : class
        where TUpdate : class
    {
        Task<TResponse> Insert(TInsert request);
        Task<TResponse> Update(int id, TUpdate request);
        Task Delete(int id);
    }
}