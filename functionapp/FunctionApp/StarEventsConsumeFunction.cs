using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Azure.Core;
using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Storage.Blobs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;


namespace star_events_consume_vs
{
    public static class StarEventsConsumeFunction
    {
        [FunctionName("star_events_consume")]
        public static async Task Run([EventHubTrigger("%EventHubName%", Connection = "EventHubNSConnection")] EventData[] events,
            ILogger log)
        {
            var exceptions = new List<Exception>();
            string blobName = Guid.NewGuid().ToString() + ".json";

            string accountName = Environment.GetEnvironmentVariable("EventsStorageAccountName");
            string containerName = Environment.GetEnvironmentVariable("EventsStorageContainerName");

            // Construct the blob container endpoint from the arguments.
            string containerEndpoint = string.Format("https://{0}.blob.core.windows.net/{1}",
                accountName,
                containerName);

            BlobContainerClient container =
                new BlobContainerClient(new Uri(containerEndpoint), new DefaultAzureCredential());

            await container.CreateIfNotExistsAsync();

            BlobClient blob = container.GetBlobClient(blobName);

            StringBuilder sb = new StringBuilder("[");
            bool firstEventInBatch = true;


            foreach (EventData eventData in events)
            {
                try
                {
                    string messageBody = Encoding.UTF8.GetString(eventData.Body.ToArray());
                    if (firstEventInBatch)
                    {
                        sb.Append(messageBody);
                        firstEventInBatch = false;
                    }
                    else
                    {
                        sb.Append(",");
                        sb.Append(messageBody);
                    }
                    // Replace these two lines with your processing logic.
                    log.LogInformation("Event Hub trigger function processed a message");
                    await Task.Yield();
                }
                catch (Exception e)
                {
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }

            }
            sb.Append("]"); // close the JSON array

            // save as new blob
            await using (var stream = GenerateStreamFromString(sb.ToString()))
            {
                try
                {
                    await blob.UploadAsync(stream);
                }
                catch (Exception e)
                {
                    exceptions.Add(e);
                }
            }

            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.
            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();
        }

        private static Stream GenerateStreamFromString(string s)
        {
            var stream = new MemoryStream();
            var writer = new StreamWriter(stream);
            writer.Write(s);
            writer.Flush();
            stream.Position = 0;
            return stream;
        }
    }

}
