using System;

namespace HireMatch.Services.Database
{
    public class Notification
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public MyAppUser User { get; set; } = default!;

        public string Type { get; set; } = default!;
        public string Message { get; set; } = default!;
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
