using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.Requests;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;
using Mapster;

namespace HireMatch.Services.Implementations
{
    public class CompanyEFService : BaseEFCRUDService<CompanyResponse, Company, CompanySearchObject, CompanyInsertRequest, CompanyUpdateRequest>, ICompanyService
    {
        public CompanyEFService(HireMatchDbContext dbContext) : base(dbContext)
        {
        }

        protected override IQueryable<Company> ApplySearchFilters(IQueryable<Company> query, CompanySearchObject search)
        {
            query = query.Include(x => x.City);

            if (search != null)
            {
                if (!string.IsNullOrWhiteSpace(search.Name))
                {
                    var name = search.Name.ToLower();
                    query = query.Where(x => x.Name.ToLower().Contains(name));
                }

                if (!string.IsNullOrWhiteSpace(search.City))
                {
                    var city = search.City.ToLower();
                    query = query.Where(x => x.City != null && x.City.Name.ToLower().Contains(city));
                }
            }
            return query;
        }

        protected override CompanyResponse MapToResponse(Company entity)
        {
            return new CompanyResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                Address = entity.Address,
                CityId = entity.CityId,
                CityName = entity.City?.Name ?? string.Empty,
                RegistrationNumber = entity.RegistrationNumber,
                Description = entity.Description,
                Website = entity.Website,
                LogoUrl = entity.LogoUrl,
                CreatedAt = entity.CreatedAt,
            };
        }

        public override async Task<CompanyResponse> Insert(CompanyInsertRequest request)
        {
            if (request == null) throw new ArgumentNullException(nameof(request));

            var entity = new Company
            {
                Name = request.Name,
                Address = request.Address,
                CityId = request.CityId,
                RegistrationNumber = request.RegistrationNumber,
                Description = request.Description,
                Website = request.Website,
                CreatedAt = DateTime.UtcNow,
            };
            _dbSet.Add(entity);
            await _dbContext.SaveChangesAsync();

            var loaded = await _dbContext.Companies
                .Include(c => c.City)
                .FirstAsync(c => c.Id == entity.Id);

            return MapToResponse(loaded);
        }

        public override async Task<CompanyResponse?> Update(int id, CompanyUpdateRequest request)
        {
            var entity = await _dbContext.Companies
                .Include(c => c.City)
                .FirstOrDefaultAsync(c => c.Id == id);
            if (entity == null) return null;

            entity.Name = request.Name;
            entity.Address = request.Address;
            entity.CityId = request.CityId;
            entity.RegistrationNumber = request.RegistrationNumber;
            entity.Description = request.Description;
            entity.Website = request.Website;

            await _dbContext.SaveChangesAsync();

            var loaded = await _dbContext.Companies
                .Include(c => c.City)
                .FirstAsync(c => c.Id == id);

            return MapToResponse(loaded);
        }
    }
}