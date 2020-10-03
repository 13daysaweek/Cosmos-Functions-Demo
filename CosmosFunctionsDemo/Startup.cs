using System;
using CosmosFunctionsDemo;
using CosmosFunctionsDemo.Services;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(Startup))]

namespace CosmosFunctionsDemo
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var database = Environment.GetEnvironmentVariable("cosmosDatabaseName");
            var container = Environment.GetEnvironmentVariable("cosmosContainerName");
            builder.Services.AddLogging();
            builder.Services.AddSingleton<IInventoryUpdateService>(_ => new InventoryUpdateService(database, container));
        }
    }
}
