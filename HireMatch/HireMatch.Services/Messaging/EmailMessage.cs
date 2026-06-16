namespace HireMatch.Services.Messaging
{
    public class EmailMessage
    {
        public string ToEmail { get; set; } = default!;
        public string Subject { get; set; } = default!;
        public string Body { get; set; } = default!;
    }
}
