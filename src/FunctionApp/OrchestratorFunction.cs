using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Azure.Messaging.ServiceBus;
using System.Text.Json;

namespace ESS.FunctionApp
{
    public class OrchestratorFunction
    {
        private readonly ILogger _logger;

        public OrchestratorFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<OrchestratorFunction>();
        }

        [Function("ProcessOrchestratorQueue")]
        public async Task ProcessOrchestratorQueue(
            [ServiceBusTrigger("orchestrator-queue", Connection = "ServiceBusConnection")] ServiceBusReceivedMessage message)
        {
            _logger.LogInformation($"Processing message: {message.MessageId}");

            try
            {
                var messageBody = message.Body.ToString();
                _logger.LogInformation($"Message content: {messageBody}");

                // Process your orchestrator logic here
                await ProcessOrchestratorLogic(messageBody);

                _logger.LogInformation($"Successfully processed message: {message.MessageId}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error processing message: {message.MessageId}");
                throw;
            }
        }

        [Function("SendToOrchestratorQueue")]
        public async Task<object> SendToOrchestratorQueue(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
        {
            _logger.LogInformation("HTTP trigger function processed a request to send message to orchestrator queue.");

            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            var serviceBusClient = new ServiceBusClient(Environment.GetEnvironmentVariable("ServiceBusConnection"));
            var sender = serviceBusClient.CreateSender(Environment.GetEnvironmentVariable("OrchestratorQueueName"));

            var message = new ServiceBusMessage(requestBody);
            await sender.SendMessageAsync(message);

            _logger.LogInformation("Message sent to orchestrator queue successfully.");

            return new { Status = "Message sent successfully", MessageId = message.MessageId };
        }

        private async Task ProcessOrchestratorLogic(string messageContent)
        {
            // Implement your orchestrator business logic here
            await Task.Delay(1000); // Simulate processing
        }
    }
}