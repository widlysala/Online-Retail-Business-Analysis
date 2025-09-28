-- filtered data --

with products as (
select
  `Product Type` as product_type,
  `Net Quantity` as quantity,
  `Total Net Sales` as sales,
  round(`Total Net Sales` / `Net Quantity`, 2) as cost_per_item
from omega-rhino-473209-s7.online_business.retail1
where `Product Type` is not null and `Net Quantity` != 0 and `Total Net Sales` != 0
),

-- product types' kpi --

cte1 as (
select
  product_type,
  sum(quantity) as total_quantity,
  round(sum(sales),1) as total_sales,
  round(avg(cost_per_item),1) as avg_cost_per_item,
  case
    when round(avg(cost_per_item),1) >= 100 then "Expensive"
    when round(avg(cost_per_item),1) >= 50 then "Mid"
    else "Cheap"
  end as price_range
from products
group by product_type
order by product_type
),

main_kpi as (
select 
  product_type,
  total_quantity,
  case
    when total_quantity > avg(total_quantity) over() then "High"
    when total_quantity < avg(total_quantity) over() and total_quantity < 100 then "Low"
    else "Average"
  end as demand,
  total_sales,
  case
    when total_sales > avg(total_sales) over() then "High"
    when total_sales < avg(total_sales) over() and total_sales < 1000 then "Poor"
    else "Average"
  end as sales_performance,
  avg_cost_per_item,
  price_range
from cte1
)

-- now we can query and filter data to gather insights --
-- f.e. find product type that has both low demand and sales performance --

/*
select 
  *
from main_kpi
where demand = "Low" and sales_performance = "Poor"
*/

-- or find ones with both high demand and expensive/average price-range, 
-- which could then become the main target of promotion, since they are within our customers interest and have a good potential for profit --

/*
select * 
from main_kpi
where demand = "High" and (price_range = "Expensive" or price_range = "Mid")
*/
