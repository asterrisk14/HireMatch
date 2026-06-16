namespace HireMatch.Services.Messaging
{
    public interface IMessagePublisher
    {
        void PublishEmail(EmailMessage message);
    }
}
