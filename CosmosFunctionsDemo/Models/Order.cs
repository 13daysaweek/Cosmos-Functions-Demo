using System.Collections.Generic;
using Microsoft.Azure.Documents;
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

        public static Order FromDocument(Document doc)
        {
            var orderString = JsonConvert.SerializeObject(doc);
            var order = JsonConvert.DeserializeObject<Order>(orderString);

            return order;
        }
    }
}
