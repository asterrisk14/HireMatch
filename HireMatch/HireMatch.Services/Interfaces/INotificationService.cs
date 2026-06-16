using System.Collections.Generic;
using System.Threading.Tasks;
using HireMatch.Model.Responses;
using HireMatch.Model.SearchObjects;
using HireMatch.Model.Result;

namespace HireMatch.Services.Interfaces
{
    public interface INotificationService
    {
        Task<PagedResult<NotificationResponse>> GetForUser(int userId, NotificationSearchObject search);
        Task<int> GetUnreadCount(int userId);
        Task MarkAsRead(int userId, int notificationId);
        Task MarkAllAsRead(int userId);
        // Interno - kreiranje notifikacije (poziva se iz drugih servisa)
        Task CreateNotification(int userId, string type, string message);
    }
}