using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using CosmosFunctionsDemo.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace CosmosFunctionsDemo
{
    public static class CreateOrder
    {
        [FunctionName("CreateOrder")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log,
            [CosmosDB(databaseName: "%cosmosDatabaseName%",
                collectionName: "%ordersContainerName%",
                ConnectionStringSetting = "cosmosConnectionString")] IAsyncCollector<Order> ordersToSave)
        {
            var order = JsonConvert.DeserializeObject<Order>(await req.ReadAsStringAsync());
            await ordersToSave.AddAsync(order);

            return new NoContentResult();
        }
    }
}
