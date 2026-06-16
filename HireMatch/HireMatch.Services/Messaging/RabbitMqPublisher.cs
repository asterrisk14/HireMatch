using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;

namespace HireMatch.Services.Messaging
{
    public class RabbitMqPublisher : IMessagePublisher, IAsyncDisposable
    {
        private readonly IConfiguration _config;
        private IConnection? _connection;
        private IChannel? _channel;
        private const string QueueName = "email_queue";
        private readonly SemaphoreSlim _initLock = new(1, 1);

        public RabbitMqPublisher(IConfiguration config)
        {
            _config = config;
        }

        private async Task EnsureInitializedAsync()
        {
            if (_channel != null) return;
            await _initLock.WaitAsync();
            try
            {
                if (_channel != null) return;
                var factory = new ConnectionFactory
                {
                    HostName = _config["RabbitMQ:Host"] ?? "localhost",
                    Port = int.TryParse(_config["RabbitMQ:Port"], out var p) ? p : 5672,
                    UserName = _config["RabbitMQ:Username"] ?? "guest",
                    Password = _config["RabbitMQ:Password"] ?? "guest",
                };
                _connection = await factory.CreateConnectionAsync();
                _channel = await _connection.CreateChannelAsync();
                await _channel.QueueDeclareAsync(queue: QueueName, durable: true, exclusive: false, autoDelete: false, arguments: null);
            }
            finally
            {
                _initLock.Release();
            }
        }

        public async void PublishEmail(EmailMessage message)
        {
            await EnsureInitializedAsync();
            var json = JsonSerializer.Serialize(message);
            var body = Encoding.UTF8.GetBytes(json);
            var properties = new BasicProperties { Persistent = true };
            await _channel!.BasicPublishAsync(exchange: "", routingKey: QueueName, mandatory: false, basicProperties: properties, body: body);
        }

        public async ValueTask DisposeAsync()
        {
            if (_channel != null) await _channel.CloseAsync();
            if (_connection != null) await _connection.CloseAsync();
        }
    }
}
