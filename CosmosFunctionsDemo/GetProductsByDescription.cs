using System.Collections.Generic;
using CosmosFunctionsDemo.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace CosmosFunctionsDemo
{
    public static class GetProductsByDescription
    {
        [FunctionName("GetProductsByDescription")]
        public static IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "search/{category}")] HttpRequest req,
            [CosmosDB(databaseName:"%cosmosDatabaseName%",
                collectionName: "%cosmosContainerName%",
                ConnectionStringSetting = "cosmosConnectionString",
                SqlQuery = "SELECT * FROM products c WHERE c.category = '{category}'")] IEnumerable<Product> products,
            ILogger log)
        {
            log.LogInformation($"Got products: {products}");
            return new OkObjectResult(products);
        }
    }
}
