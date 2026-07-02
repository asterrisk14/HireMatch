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
    public class BaseEFReadService<TResponse, TEntity, TSearch> : IBaseReadService<TResponse, TSearch>
        where TResponse : class
        where TEntity : class
        where TSearch : BaseSearchObject
    {
        protected readonly HireMatchDbContext _dbContext;
        protected readonly DbSet<TEntity> _dbSet;

        public BaseEFReadService(HireMatchDbContext dbContext)
        {
            _dbContext = dbContext;
            _dbSet = _dbContext.Set<TEntity>();
        }

        /// <summary>
        /// Override this method to apply custom filtering logic
        /// </summary>
        protected virtual IQueryable<TEntity> ApplySearchFilters(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }

        public virtual async Task<PagedResult<TResponse>> Get(TSearch search)
        {
            var query = _dbSet.AsNoTracking();
            query = ApplySearchFilters(query, search);

            var result = new PagedResult<TResponse>();

            // 1. Prvo prebrojimo zapise direktno na SQL serveru
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

            result.Result = entities.Select(e => e.Adapt<TResponse>()).ToList();

            return result;
        }

        public virtual async Task<TResponse?> GetById(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity?.Adapt<TResponse>();
        }
    }
}
