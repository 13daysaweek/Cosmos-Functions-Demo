using System.Collections.Generic;
using CosmosFunctionsDemo.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace CosmosFunctionsDemo.Functions
{
    public static class GetProductsByDescription
    {
        [FunctionName("GetProductsByDescription")]
        public static IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "search/{description}")] HttpRequest req,
            [CosmosDB(databaseName:"%cosmosDatabaseName%",
                collectionName: "%cosmosContainerName%",
                ConnectionStringSetting = "cosmosConnectionString",
                SqlQuery = "SELECT * FROM c WHERE CONTAINS(c.description, {description}, true)")] IEnumerable<Product> products,
            ILogger log)
        {
            return new OkObjectResult(products);
        }
    }
}
