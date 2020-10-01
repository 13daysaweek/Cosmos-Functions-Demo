using System.Collections.Generic;
using Newtonsoft.Json;

namespace CosmosFunctionsDemo.Models
{
    public class Order
    {
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("customerNumber")]
        public string CustomerNumber { get; set; }

        [JsonProperty("lineItems")]
        public IList<OrderLineItem> LineItems { get; set; }
    }
}
