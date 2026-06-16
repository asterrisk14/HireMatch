using System;

namespace HireMatch.Services.Database
{
    public class CareerTip
    {
        public int Id { get; set; }
        public string Title { get; set; } = default!;
        public string Content { get; set; } = default!;
        public string Icon { get; set; } = "💡";
        public DateTime CreatedAt { get; set; }
    }
}