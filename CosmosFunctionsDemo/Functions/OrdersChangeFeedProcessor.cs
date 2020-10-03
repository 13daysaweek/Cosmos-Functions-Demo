using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CosmosFunctionsDemo.Models;
using CosmosFunctionsDemo.Services;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace CosmosFunctionsDemo.Functions
{
    public class OrdersChangeFeedProcessor
    {
        private readonly IInventoryUpdateService _inventoryUpdateService;

        public OrdersChangeFeedProcessor(IInventoryUpdateService inventoryUpdateService)
        {
            _inventoryUpdateService = inventoryUpdateService ?? throw new ArgumentNullException(nameof(inventoryUpdateService));
        }

        [FunctionName("OrdersChangeFeedProcessor")]
        public async Task Run([CosmosDBTrigger(
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
                foreach (var doc in input)
                {
                    var order = Order.FromDocument(doc);

                    foreach (var lineItem in order.LineItems)
                    {
                        await _inventoryUpdateService.UpdateAvailableInventoryAsync(documentClient, lineItem);
                    }
                }
            }
        }
    }
}
