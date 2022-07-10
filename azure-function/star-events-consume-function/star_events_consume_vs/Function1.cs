using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Azure.Storage.Blobs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;

namespace star_events_consume_vs
{
    public static class Function1
    {
        [FunctionName("Function1")]
        public static async Task Run([EventHubTrigger("stareventhub", Connection = "stareventhubsns_RootManageSharedAccessKey_EVENTHUB")] EventData[] events,
            ILogger log)
        {
            var exceptions = new List<Exception>();
            string containerName = "star-landing";
            string blobName = Guid.NewGuid().ToString() + ".json";
            BlobContainerClient container =
                new BlobContainerClient("DefaultEndpointsProtocol=https;AccountName=adrstorageaccount2;AccountKey=MKARRoe680SvZqpv/hvMtrGVO9u/65I06gmtq7xpdLjABz7Hlv1LpRYQb2y1pg+KSWtbT/oY1gFW/WersHUgfA==",containerName);

            await container.CreateIfNotExistsAsync();

            BlobClient blob = container.GetBlobClient(blobName);




            StringBuilder sb = new StringBuilder("[");
            //outputBlob.WriteLine("[");
            bool firstEventInBatch = true;


            foreach (EventData eventData in events)
            {
                try
                {
                    string messageBody = Encoding.UTF8.GetString(eventData.Body.ToArray());
                    if (firstEventInBatch)
                    {
                        sb.Append(messageBody);
                        //outputBlob.WriteLine(messageBody);
                        firstEventInBatch = false;
                    }
                    else
                    {
                        //outputBlob.WriteLine.(",");
                        sb.Append(",");
                        //outputBlob.WriteLine(messageBody);
                        sb.Append(messageBody);
                    }
                    // Replace these two lines with your processing logic.
                    log.LogInformation($"C# Event Hub trigger function processed a message: {messageBody}");
                    await Task.Yield();
                }
                catch (Exception e)
                {
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }

            }

            sb.Append("]");
            await blob.UploadAsync(sb.ToString());
            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();

























            foreach (EventData eventData in events)
            {
                try
                {
                    // Replace these two lines with your processing logic.
                    log.LogInformation($"C# Event Hub trigger function processed a message: {eventData.EventBody}");
                    await Task.Yield();
                }
                catch (Exception e)
                {
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }
            }

            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();
        }
    }
}
