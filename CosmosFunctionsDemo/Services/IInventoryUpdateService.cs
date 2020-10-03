using System.Threading.Tasks;
using Microsoft.Azure.Documents;

namespace CosmosFunctionsDemo.Services
{
    public interface IInventoryUpdateService
    {
        Task UpdateAvailableInventoryAsync(IDocumentClient documentClient, string productNumber, int quantity);
    }
}