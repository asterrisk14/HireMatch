using System;

namespace HireMatch.Services.Database
{
    public class Message
    {
        public int Id { get; set; }
        public int SenderId { get; set; }
        public MyAppUser Sender { get; set; } = default!;

        public int ReceiverId { get; set; }
        public MyAppUser Receiver { get; set; } = default!;

        public int JobPostId { get; set; }
        public JobPost JobPost { get; set; } = default!;

        public string Content { get; set; } = default!;
        public DateTime SentAt { get; set; }
    }
}
