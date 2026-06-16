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

    public Worker(ILogger<Worker> logger, IConfiguration config)
    {
        _logger = logger;
        _config = config;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _config["RabbitMQ:Host"] ?? "localhost",
            Port = int.TryParse(_config["RabbitMQ:Port"], out var p) ? p : 5672,
            UserName = _config["RabbitMQ:Username"] ?? "guest",
            Password = _config["RabbitMQ:Password"] ?? "guest"
        };

        using var connection = await factory.CreateConnectionAsync(stoppingToken);
        using var channel = await connection.CreateChannelAsync(cancellationToken: stoppingToken);

        await channel.QueueDeclareAsync(queue: "email_queue", durable: true, exclusive: false, autoDelete: false, cancellationToken: stoppingToken);

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
                _logger.LogError("Neispravan format poruke: {ex}", ex.Message);
            }

            if (email != null)
            {
                await SendEmailWithRetryAsync(email, stoppingToken);
            }
        };

        await channel.BasicConsumeAsync(queue: "email_queue", autoAck: true, consumer: consumer, cancellationToken: stoppingToken);

        _logger.LogInformation("Worker ceka poruke...");
        await Task.Delay(Timeout.Infinite, stoppingToken);
    }

    private async Task SendEmailWithRetryAsync(EmailMessage email, CancellationToken token)
    {
        int[] delays = { 1000, 2000, 4000, 8000 };
        for (int attempt = 0; attempt <= delays.Length; attempt++)
        {
            try
            {
                await SendEmailAsync(email, token);
                _logger.LogInformation("Email poslan na {to}", email.ToEmail);
                return;
            }
            catch (Exception ex)
            {
                if (attempt == delays.Length)
                {
                    _logger.LogError("Email nije poslan nakon {n} pokusaja: {ex}", attempt + 1, ex.Message);
                    return;
                }
                _logger.LogWarning("Pokusaj {n} neuspjesan, ponavljam za {ms}ms: {ex}", attempt + 1, delays[attempt], ex.Message);
                await Task.Delay(delays[attempt], token);
            }
        }
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
