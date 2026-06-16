using System;

namespace HireMatch.Model.Responses
{
    public class CareerTipResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = default!;
        public string Content { get; set; } = default!;
        public string Icon { get; set; } = default!;
        public DateTime CreatedAt { get; set; }
    }
}