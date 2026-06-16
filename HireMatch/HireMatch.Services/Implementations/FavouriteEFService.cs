using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;

namespace HireMatch.Services.Implementations
{
    public class FavouriteEFService : BaseEFCRUDService<FavouriteResponse, Favourite, FavouriteSearchObject, FavouriteInsertRequest, FavouriteUpdateRequest>, IFavouriteService
    {
        public FavouriteEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<Favourite> ApplySearchFilters(IQueryable<Favourite> query, FavouriteSearchObject search)
        {
            query =query
            .Include(f => f.JobPost).ThenInclude(j => j.Company)
            .Include(f => f.JobPost).ThenInclude(j => j.EmploymentType)
            .Include(f => f.JobPost).ThenInclude(j => j.City);

            if (search?.CandidateId != null)
                query = query.Where(f => f.CandidateId == search.CandidateId.Value);

            return query.OrderByDescending(f => f.CreatedAt);
        }

        protected override FavouriteResponse MapToResponse(Favourite entity)
        {
            return new FavouriteResponse
            {
                Id = entity.Id,
                CandidateId = entity.CandidateId,
                JobPostId = entity.JobPostId,
                JobPostTitle = entity.JobPost?.Title ?? string.Empty,
                CompanyName = entity.JobPost?.Company?.Name ?? string.Empty,
                CompanyLogoUrl = entity.JobPost?.Company?.LogoUrl ?? string.Empty,
                Location = entity.JobPost?.City?.Name ?? string.Empty,  
                EmploymentTypeName = entity.JobPost?.EmploymentType?.Name ?? string.Empty,
                ExpiryDate = entity.JobPost?.ExpiryDate ?? default,
                CreatedAt = entity.CreatedAt,
            };
        }

        public override async Task<FavouriteResponse> Insert(FavouriteInsertRequest request)
        {
            var existing = await _dbContext.Favourites
                .Include(f => f.JobPost).ThenInclude(j => j.Company)
                .Include(f => f.JobPost).ThenInclude(j => j.EmploymentType)
                .FirstOrDefaultAsync(f => f.CandidateId == request.CandidateId && f.JobPostId == request.JobPostId);

            if (existing != null)
                return MapToResponse(existing);

            var entity = new Favourite
            {
                CandidateId = request.CandidateId,
                JobPostId = request.JobPostId,
                CreatedAt = DateTime.UtcNow,
            };

            _dbSet.Add(entity);
            await _dbContext.SaveChangesAsync();

            var loaded = await _dbContext.Favourites
                .Include(f => f.JobPost).ThenInclude(j => j.Company)
                .Include(f => f.JobPost).ThenInclude(j => j.EmploymentType)
                .FirstAsync(f => f.Id == entity.Id);

            return MapToResponse(loaded);
        }
    }
}