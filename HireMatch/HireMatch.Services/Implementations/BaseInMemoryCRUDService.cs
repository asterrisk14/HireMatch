using System.Linq;
using System.Threading.Tasks;
using HireMatch.Services.Interfaces;
using HireMatch.Model.SearchObjects;
using Mapster;

namespace HireMatch.Services
{
    public class BaseInMemoryCRUDService<TResponse, TEntity, TSearch, TInsert, TUpdate> : BaseInMemoryReadService<TResponse, TEntity, TSearch>, IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate>
        where TResponse : class
        where TEntity : class
        where TSearch : BaseSearchObject
        where TInsert : class
        where TUpdate : class
    {
        public BaseInMemoryCRUDService(List<TEntity> data) : base(data)
        {
        }

        public async Task<TResponse> Insert(TInsert request)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));
            var entity = request.Adapt<TEntity>();
            // Assume entities have an Id property
            var idProperty = typeof(TEntity).GetProperty("Id");
            if (idProperty != null && idProperty.PropertyType == typeof(int))
            {
                var maxId = _data.Any() ? _data.Max(e => (int)idProperty.GetValue(e)!) : 0;
                idProperty.SetValue(entity, maxId + 1);
            }
            _data.Add(entity);
            return entity.Adapt<TResponse>();
        }

        public async Task<TResponse> Update(int id, TUpdate request)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));
            var entity = _data.FirstOrDefault(e => (e as dynamic).Id == id);
            if (entity == null)
            {
                throw new KeyNotFoundException($"Entity with id {id} not found");
            }
            request.Adapt(entity);
            return entity.Adapt<TResponse>();
        }

        public async Task Delete(int id)
        {
            var entity = _data.FirstOrDefault(e => (e as dynamic).Id == id);
            if (entity != null)
            {
                _data.Remove(entity);
            }
        }
    }
}