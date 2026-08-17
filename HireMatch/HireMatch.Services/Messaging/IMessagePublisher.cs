namespace HireMatch.Services.Messaging
{
    public interface IMessagePublisher
    {
        Task PublishEmail(EmailMessage message);
    }
}
