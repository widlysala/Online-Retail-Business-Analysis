-- check for duplicates (by year + month) --

/*
select *
from (
  select
    Year,
    Month,
    row_number() over(partition by Year, Month order by Year, Month) as rnk
  from omega-rhino-473209-s7.online_business.retail2
)
where rnk > 1
*/

-- clear date (year-month format), total_orders, net_sales (w/o shipping, and after discounts & returns) --

with sales as (
  select 
    CAST(CONCAT(
        CAST(year AS STRING),
        "-",
        LPAD(CAST(EXTRACT(MONTH FROM PARSE_DATE('%B', month)) AS STRING), 2, '0'),
        "-01"
    ) as date) AS period,
    `Total Orders` as total_orders,
    `Net Sales` as net_sales
  from omega-rhino-473209-s7.online_business.retail2
),

-- net_sales by quarter --

sales_pq as (
  select 
    concat(
      substring(cast(date_trunc(period, year) as string),1,4),
      " Q",
      extract(quarter from (cast(period as date)))
    ) as q,
    sum(total_orders) as total_orders_pq,
    round(sum(net_sales),2) as net_sales_pq
  from sales
  group by 
    concat(
      substring(cast(date_trunc(period, year) as string),1,4),
      " Q",
      extract(quarter from (cast(period as date)))
    )
),

-- diff in net_sales compared to prev. quarter, both by number and % change --

prev_q as (
  select 
    q,
    total_orders_pq,
    prev_orders,
    total_orders_pq - prev_orders as prev_orders_diff,
    case
      when prev_orders = 0 then 0
      else round(((total_orders_pq - prev_orders) / prev_orders) * 100, 0)
    end as perc_change_orders,
    net_sales_pq,
    prev_q,
    round(net_sales_pq - prev_q, 2) as prev_q_diff,
    case 
      when prev_q = 0 then 0
      else round(((net_sales_pq - prev_q) / prev_q) * 100, 0)
    end as perc_change_sales 
  from (
    select 
      *,
      lag(net_sales_pq, 1, 0) over(order by q) as prev_q,
      lag(total_orders_pq, 1, 0) over(order by q) as prev_orders
    from sales_pq
    order by q
  )
),

-- ctes for calculating current quarter (the most recent) + avg diff in net_sales and total_sales compared to prev. quarter or/and year --

avg_diffyq as (
  select 
    round(avg(prev_q_diff),2) as avg_diff
  from(
    -- we don't want to have 1st row as there is no comparison w previous quarter, making this value in prev_q_diff uninsightful --
    select *, row_number() over(order by q) as rnk
    from prev_q
  )
  where rnk != 1
),

latest_q as (
  select 
    q,
    net_sales_pq
  from prev_q
  where q in (select max(q) from prev_q)
),

avg_diffq as (
  select
    regexp_extract(q, r'Q[1-4]') as q,
    avg(prev_q_diff) as diff_eachq
  from(
      -- we don't want to have 1st row as there is no comparison w previous quarter, making this value in prev_q_diff uninsightful --
      select 
        *, 
        row_number() over(order by q) as rnk
      from prev_q
    )
  where rnk != 1
  group by regexp_extract(q, r'Q[1-4]')
  order by regexp_extract(q, r'Q[1-4]')
)

-- forecast next quarter --

select 
  "next quarter's expected net sales by: avg % change each quarter across the record history" as q,
  -- the reason why we + and not - is beacuse if the average difference ever will be negative then - on + will give -, 
  -- but if we - them then negative value will contribute positively, which doesn't make sense.
  -- also, we're predicting value of the next quarter, so the current value acts as a "previous quarter" which we +ing the average difference on,
  -- as if (current quarter sales - previous quarter sales = difference), but (next quarter sales - current quarter sales = usual difference according to the records history) 
  lq.net_sales_pq + ad.avg_diff as forecast_nq
from avg_diffyq ad
cross join latest_q lq

union all

select 
  "next quarter's expected net sales by: avg % change within the quarter (despite year)",
  round (
  case
    when lq.q like "%Q1" then lq.net_sales_pq + ad2.diff_eachq
    when lq.q like "%Q2" then lq.net_sales_pq + ad2.diff_eachq
    when lq.q like "%Q3" then lq.net_sales_pq + ad2.diff_eachq
    when lq.q like "%Q4" then lq.net_sales_pq + ad2.diff_eachq
  end,2)
from avg_diffq ad2
join latest_q lq 
  on regexp_extract(lq.q, r'Q[1-4]') = ad2.q


