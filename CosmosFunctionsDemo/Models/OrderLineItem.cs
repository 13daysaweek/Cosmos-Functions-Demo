using Newtonsoft.Json;

namespace CosmosFunctionsDemo.Models
{
    public class OrderLineItem
    {
        [JsonProperty("productId")]
        public string ProductId { get; set; }

        [JsonProperty("quantity")]
        public int Quantity { get; set; }

        [JsonProperty("category")]
        public string Category { get; set; }
    }
}