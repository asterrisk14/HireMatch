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
    public class CareerTipEFService : BaseEFCRUDService<CareerTipResponse, CareerTip, CareerTipSearchObject, CareerTipInsertRequest, CareerTipUpdateRequest>, ICareerTipService
    {
        public CareerTipEFService(HireMatchDbContext context) : base(context) { }

        protected override IQueryable<CareerTip> ApplySearchFilters(IQueryable<CareerTip> query, CareerTipSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search?.Title))
                query = query.Where(x => x.Title.ToLower().Contains(search.Title.ToLower()));

            return query.OrderByDescending(x => x.CreatedAt);
        }

        public override async Task<CareerTipResponse> Insert(CareerTipInsertRequest request)
        {
            var entity = new CareerTip
            {
                Title = request.Title,
                Content = request.Content,
                Icon = string.IsNullOrWhiteSpace(request.Icon) ? "💡" : request.Icon,
                CreatedAt = DateTime.UtcNow,
            };
            _dbSet.Add(entity);
            await _dbContext.SaveChangesAsync();
            return MapToResponse(entity);
        }
    }
}