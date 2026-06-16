using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.SearchObjects;
using HireMatch.Model.Result;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using Mapster;

namespace HireMatch.Services.Implementations
{
    public class BaseEFCRUDService<TResponse, TEntity, TSearch, TInsert, TUpdate> : IBaseCRUDService<TResponse, TSearch, TInsert, TUpdate>
        where TResponse : class
        where TEntity : class
        where TSearch : BaseSearchObject
        where TInsert : class
        where TUpdate : class
    {
        protected readonly HireMatchDbContext _dbContext;
        protected readonly DbSet<TEntity> _dbSet;

        public BaseEFCRUDService(HireMatchDbContext dbContext)
        {
            _dbContext = dbContext;
            _dbSet = _dbContext.Set<TEntity>();
        }

        
        protected virtual IQueryable<TEntity> ApplySearchFilters(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }

        public virtual async Task<PagedResult<TResponse>> Get(TSearch search)
        {
            var query = _dbSet.AsNoTracking(); 
            query = ApplySearchFilters(query, search);

            var result = new PagedResult<TResponse>();

            if (search?.RetrieveTotalCount == true)
            {
                result.TotalCount = await query.CountAsync();
            }

            if (search?.Page.HasValue == true && search.PageSize.HasValue)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var entities = await query.ToListAsync();

            result.Result = entities.Select(e => MapToResponse(e)).ToList();
            return result;
        }

        public virtual async Task<TResponse?> GetById(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity?.Adapt<TResponse>();
        }

        public virtual async Task<TResponse> Insert(TInsert request)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));

            var entity = request.Adapt<TEntity>();
            _dbSet.Add(entity);
            await _dbContext.SaveChangesAsync();

            return entity.Adapt<TResponse>();
        }

        public virtual async Task<TResponse?> Update(int id, TUpdate request)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));

            var entity = await _dbSet.FindAsync(id);
            if (entity == null) return null;

            request.Adapt(entity);
            
            _dbSet.Update(entity);
            await _dbContext.SaveChangesAsync();

            return entity.Adapt<TResponse>();
        }

        public virtual async Task Delete(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            if (entity != null)
            {
                _dbSet.Remove(entity);
                await _dbContext.SaveChangesAsync();
            }
        }

        protected virtual TResponse MapToResponse(TEntity entity)
        {
         return entity.Adapt<TResponse>();
        }
    }
}