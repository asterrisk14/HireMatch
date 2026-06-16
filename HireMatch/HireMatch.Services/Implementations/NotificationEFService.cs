using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Model.Result;
using HireMatch.Services.Database;
using HireMatch.Services.Interfaces;

namespace HireMatch.Services.Implementations
{
    public class NotificationEFService : INotificationService
    {
        private readonly HireMatchDbContext _dbContext;

        public NotificationEFService(HireMatchDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<PagedResult<NotificationResponse>> GetForUser(int userId, NotificationSearchObject search)
        {
            var query = _dbContext.Notifications
                .AsNoTracking()
                .Where(n => n.UserId == userId);

            if (search?.IsRead != null)
                query = query.Where(n => n.IsRead == search.IsRead.Value);

            query = query.OrderByDescending(n => n.CreatedAt);

            var result = new PagedResult<NotificationResponse>();

            if (search?.RetrieveTotalCount == true)
                result.TotalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search.PageSize.HasValue)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var items = await query.ToListAsync();
            result.Result = items.Select(n => new NotificationResponse
            {
                Id = n.Id,
                Type = n.Type,
                Message = n.Message,
                IsRead = n.IsRead,
                CreatedAt = n.CreatedAt
            }).ToList();

            return result;
        }

        public async Task<int> GetUnreadCount(int userId)
        {
            return await _dbContext.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .CountAsync();
        }

        public async Task MarkAsRead(int userId, int notificationId)
        {
            var notif = await _dbContext.Notifications
                .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);
            if (notif != null && !notif.IsRead)
            {
                notif.IsRead = true;
                await _dbContext.SaveChangesAsync();
            }
        }

        public async Task MarkAllAsRead(int userId)
        {
            var unread = await _dbContext.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();
            foreach (var n in unread)
                n.IsRead = true;
            await _dbContext.SaveChangesAsync();
        }

        public async Task CreateNotification(int userId, string type, string message)
        {
            var notif = new Notification
            {
                UserId = userId,
                Type = type,
                Message = message,
                IsRead = false,
                CreatedAt = DateTime.UtcNow
            };
            _dbContext.Notifications.Add(notif);
            await _dbContext.SaveChangesAsync();
        }
    }
}