using System.Collections.Generic;
using System.Runtime.InteropServices.ComTypes;
using CosmosFunctionsDemo.Models;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace CosmosFunctionsDemo
{
    public static class OrdersChangeFeedProcessor
    {
        [FunctionName("OrdersChangeFeedProcessor")]
        public static void Run([CosmosDBTrigger(
            databaseName: "%cosmosDatabaseName%",
            collectionName: "%ordersContainerName%",
            ConnectionStringSetting = "cosmosConnectionString",
            LeaseCollectionName = "leases",
            CreateLeaseCollectionIfNotExists = true,
            LeaseCollectionPrefix = "orderCreate")]IReadOnlyList<Document> input, 
            [CosmosDB(ConnectionStringSetting = "cosmosConnectionString")]IDocumentClient documentClient,
            ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified " + input.Count);
                log.LogInformation("First document Id " + input[0].Id);

                foreach (var doc in input)
                {
                    var order = Order.FromDocument(doc);
                    log.LogInformation(order.CustomerNumber);
                }
            }
        }
    }
}
