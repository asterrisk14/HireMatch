using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MailKit.Net.Smtp;
using MimeKit;
using HireMatch.Services.Messaging;

namespace HireMatch.Worker;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly IConfiguration _config;
    private const string QueueName = "email_queue";
    private const string DeadLetterQueueName = "email_queue_dead";
    private const string DeadLetterExchange = "email_dead_letter_exchange";

    public Worker(ILogger<Worker> logger, IConfiguration config)
    {
        _logger = logger;
        _config = config;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        IConnection? connection = null;
        var retries = 0;
        while (connection == null && retries < 10)
        {
            try
            {
                var factory = new ConnectionFactory
                {
                    HostName = _config["RabbitMQ:Host"] ?? "localhost",
                    Port = int.TryParse(_config["RabbitMQ:Port"], out var p) ? p : 5672,
                    UserName = _config["RabbitMQ:Username"] ?? "guest",
                    Password = _config["RabbitMQ:Password"] ?? "guest"
                };
                connection = await factory.CreateConnectionAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                retries++;
                _logger.LogWarning("RabbitMQ nije dostupan, pokusaj {n}/10. Cekam 5s... {ex}", retries, ex.Message);
                await Task.Delay(5000, stoppingToken);
            }
        }

        if (connection == null)
        {
            _logger.LogError("Nije moguce spojiti na RabbitMQ nakon 10 pokusaja.");
            return;
        }

        using var channel = await connection.CreateChannelAsync(cancellationToken: stoppingToken);

        await channel.ExchangeDeclareAsync(
            exchange: DeadLetterExchange,
            type: "direct",
            durable: true,
            cancellationToken: stoppingToken);

        await channel.QueueDeclareAsync(
            queue: DeadLetterQueueName,
            durable: true,
            exclusive: false,
            autoDelete: false,
            cancellationToken: stoppingToken);

        await channel.QueueBindAsync(
            queue: DeadLetterQueueName,
            exchange: DeadLetterExchange,
            routingKey: QueueName,
            cancellationToken: stoppingToken);

        var queueArgs = new Dictionary<string, object?>
        {
            { "x-dead-letter-exchange", DeadLetterExchange },
            { "x-dead-letter-routing-key", QueueName }
        };

        await channel.QueueDeclareAsync(
            queue: QueueName,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: queueArgs,
            cancellationToken: stoppingToken);

        await channel.BasicQosAsync(prefetchSize: 0, prefetchCount: 1, global: false, cancellationToken: stoppingToken);

        var consumer = new AsyncEventingBasicConsumer(channel);
        consumer.ReceivedAsync += async (model, ea) =>
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            _logger.LogInformation("Primljena poruka: {json}", json);

            EmailMessage? email = null;
            try
            {
                email = JsonSerializer.Deserialize<EmailMessage>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            catch (Exception ex)
            {
                _logger.LogError("Neispravan format poruke, saljem u dead-letter: {ex}", ex.Message);
                await channel.BasicNackAsync(ea.DeliveryTag, multiple: false, requeue: false);
                return;
            }

            if (email == null)
            {
                _logger.LogError("Email poruka je null, saljem u dead-letter.");
                await channel.BasicNackAsync(ea.DeliveryTag, multiple: false, requeue: false);
                return;
            }

            var success = await SendEmailWithRetryAsync(email, stoppingToken);
            if (success)
            {
                await channel.BasicAckAsync(ea.DeliveryTag, multiple: false);
            }
            else
            {
                _logger.LogError("Email nije poslan nakon svih pokusaja, saljem u dead-letter: {to}", email.ToEmail);
                await channel.BasicNackAsync(ea.DeliveryTag, multiple: false, requeue: false);
            }
        };

        await channel.BasicConsumeAsync(queue: QueueName, autoAck: false, consumer: consumer, cancellationToken: stoppingToken);

        _logger.LogInformation("Worker ceka poruke...");
        await Task.Delay(Timeout.Infinite, stoppingToken);
    }

    private async Task<bool> SendEmailWithRetryAsync(EmailMessage email, CancellationToken token)
    {
        int[] delays = { 1000, 2000, 4000, 8000 };
        for (int attempt = 0; attempt <= delays.Length; attempt++)
        {
            try
            {
                await SendEmailAsync(email, token);
                _logger.LogInformation("Email poslan na {to}", email.ToEmail);
                return true;
            }
            catch (Exception ex)
            {
                if (attempt == delays.Length)
                {
                    _logger.LogError("Email nije poslan nakon {n} pokusaja: {ex}", attempt + 1, ex.Message);
                    return false;
                }
                _logger.LogWarning("Pokusaj {n} neuspjesan, ponavljam za {ms}ms: {ex}", attempt + 1, delays[attempt], ex.Message);
                await Task.Delay(delays[attempt], token);
            }
        }
        return false;
    }

    private async Task SendEmailAsync(EmailMessage emailMsg, CancellationToken token)
    {
        var message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse("noreply@hirematch.com"));
        message.To.Add(MailboxAddress.Parse(emailMsg.ToEmail));
        message.Subject = emailMsg.Subject;
        message.Body = new TextPart(MimeKit.Text.TextFormat.Plain) { Text = emailMsg.Body };

        using var smtp = new SmtpClient();
        await smtp.ConnectAsync(_config["Smtp:Host"], int.Parse(_config["Smtp:Port"] ?? "2525"), MailKit.Security.SecureSocketOptions.StartTls, token);
        await smtp.AuthenticateAsync(_config["Smtp:Username"], _config["Smtp:Password"], token);
        await smtp.SendAsync(message, token);
        await smtp.DisconnectAsync(true, token);
    }
}