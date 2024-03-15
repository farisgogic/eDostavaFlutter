using eDostava.Services.RabbitMQ;
using Newtonsoft.Json;
using RabbitMQ.Client;
using System;
using System.Text;

namespace eDostava.Services.RabbitMQ
{
    public class MailProducer : IMailProducer
    {
        public void SendMessage<T>(T message)
        {
            var factory = new ConnectionFactory
            {
                HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "",
                Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
                UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
                Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
            };
            factory.ClientProvidedName = "Rabbit Test";

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                string exchangeName = "EmailExchange";
                string routingKey = "email_queue";
                string queueName = "EmailQueue_";

                channel.ExchangeDeclare(exchangeName, ExchangeType.Direct);
                channel.QueueDeclare(queueName, true, false, false, null);
                channel.QueueBind(queueName, exchangeName, routingKey, null);

                string emailModelJson = JsonConvert.SerializeObject(message);
                byte[] messageBodyBytes = Encoding.UTF8.GetBytes(emailModelJson);
                channel.BasicPublish(exchangeName, routingKey, null, messageBodyBytes);
            }
        }
    }
}
