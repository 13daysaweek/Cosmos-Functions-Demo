using System.Threading.Tasks;
using CosmosFunctionsDemo.Models;
using Microsoft.Azure.Documents;

namespace CosmosFunctionsDemo.Services
{
    public interface IInventoryUpdateService
    {
        Task UpdateAvailableInventoryAsync(IDocumentClient documentClient, OrderLineItem lineItem);
    }
}