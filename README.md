# Retail Business Analysis
## Short overview of the project
  This dashboard will be devide into 2 main parts, where I will showcase the business' products and sales KPI analysis respectively, based on the collected data of a real small retail online business. You can find the [original datasets](uploaded/orig.datasets), as well as [SQL queries](uploaded/sql.queries) and [tables](uploaded/finalised.tables) used for the final reporting, by clicking on the text.

  <b>*Please note</b> that the sales and products tables do not relate. The data is very limited, so I tried my best to extract the most valuable insights.

## Products' KPI
All the charts are ranged from Jan 2017 to Dec 2019.

### Overall Performance

  The following chart shows us how the company's Net Sales are related to the Demand, giving us a perspective on what product types perform better than the others. The demand is calculated by sold goods and not total orders!, where if the quantity is bigger than the average across all product types, it's given to be "High", where if it's lower and also smaller than 100 - "Low", everything else falls in-between - "Average". 

![Graph1](uploaded/visual/Net%20Sales.png)

  From this graph, you can clearly see that "Gift Basket" and "Easter" are the weakest in performance, both by demand and total profits.

  You could also notice that the top 3 performers in the low demand category have bigger net sales than some products from the average one. This is a good sign, indicating the presence of bulk buyers and their solvency.

  And yet, the top performers across all products are those with the highest demand, placing low- and average-demand sectors on the same level by comparison.

### Customers' Solvency

  The image below ilustrates the relationship between the total amount of Goods Ordered and Price Ranges.
Range of the product is calculated by its average, and according to the quartiles method.

![Graph2](uploaded/visual/Demand)

  One more time we are being convinced that "Easter" and "Gift Baskets" are the weakest performers, all their net sales come from the only order. Whereas, surprisingly, the most demanded products fall into the expensive and average price ranges, though only one or two of them, other products from the same range can't even compete with those in the cheap category.

  Grouping by price ranges, and despite a clear spike on the graph, we can find out that cheap range is taking a lead by total of 3167 goods being sold. Descendingly follows mid range with 1942, and expensive - 1473.

  Cheap range products are taking over by quantity, but it doesn't mutually exclude the fact that customers are solvent if the product is in their best interest. 

### Conclusion

Net Sales are directly impacted by total Goods Ordered, meanwhile Orders 
