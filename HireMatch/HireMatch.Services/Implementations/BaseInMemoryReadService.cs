using System.Linq;
using System.Threading.Tasks;
using HireMatch.Services.Interfaces;
using HireMatch.Model.SearchObjects;
using HireMatch.Model.Result;
using Mapster;

namespace HireMatch.Services
{
    public class BaseInMemoryReadService<TResponse, TEntity, TSearch> : IBaseReadService<TResponse, TSearch>
        where TResponse : class
        where TEntity : class
        where TSearch : BaseSearchObject
    {
        protected List<TEntity> _data;

        public BaseInMemoryReadService(List<TEntity> data)
        {
            _data = data;
        }

        public virtual async Task<PagedResult<TResponse>> Get(TSearch search)
        {
            var query = _data.AsQueryable();

            // Apply search filters if needed
            // For simplicity, just return all for now

            var list = query.ToList();
            var result = new PagedResult<TResponse>
            {
                Result = list.Adapt<List<TResponse>>(),
                TotalCount = list.Count
            };
            return result;
        }

        public async Task<TResponse?> GetById(int id)
        {
            var entity = _data.FirstOrDefault(e => (e as dynamic).Id == id);
            if (entity == null)
            {
                return default;
            }
            return entity.Adapt<TResponse>();
        }
    }
}