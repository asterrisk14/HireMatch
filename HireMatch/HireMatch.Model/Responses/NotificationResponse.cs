using System;

namespace HireMatch.Model.Responses
{
    public class NotificationResponse
    {
        public int Id { get; set; }
        public string Type { get; set; } = default!;
        public string Message { get; set; } = default!;
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}