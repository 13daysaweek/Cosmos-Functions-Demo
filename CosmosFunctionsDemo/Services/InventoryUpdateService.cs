using System;
using System.Threading.Tasks;
using CosmosFunctionsDemo.Models;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;

namespace CosmosFunctionsDemo.Services
{
    public class InventoryUpdateService : IInventoryUpdateService
    {
        private readonly string _databaseName;
        private readonly string _containerName;
        private readonly Uri _containerUri;

        public InventoryUpdateService(string databaseName, string containerName)
        {
            if (string.IsNullOrEmpty(databaseName))
            {
                throw new ArgumentException(nameof(databaseName));
            }

            _databaseName = databaseName;

            if (string.IsNullOrEmpty(containerName))
            {
                throw new ArgumentException(nameof(containerName));
            }

            _containerName = containerName;

            _containerUri = UriFactory.CreateDocumentCollectionUri(_databaseName, _containerName);
        }

        public async Task UpdateAvailableInventoryAsync(IDocumentClient documentClient, string productNumber, int quantity)
        {
            var documentUri = UriFactory.CreateDocumentUri(_databaseName, _containerName, productNumber);

            var productResponse = await documentClient.ReadDocumentAsync<Product>(documentUri);

            productResponse.Document.AvailableInventory -= quantity;

            await documentClient.UpsertDocumentAsync(_containerUri, productResponse.Document);
        }
    }
}
