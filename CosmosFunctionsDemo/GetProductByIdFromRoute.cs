using System.Threading.Tasks;
using CosmosFunctionsDemo.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace CosmosFunctionsDemo
{
    public static class GetProductByIdFromRoute
    {
        [FunctionName("GetProductByIdFromRoute")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "{category}/{id}")] HttpRequest req,
            [CosmosDB(databaseName:"%cosmosDatabaseName%",
                collectionName: "%cosmosContainerName%",
                ConnectionStringSetting = "cosmosConnectionString",
                Id = "{id}",
                PartitionKey = "{category}")] Product product,
            ILogger log)
        {
            return new OkObjectResult(product);
        }
    }
}
