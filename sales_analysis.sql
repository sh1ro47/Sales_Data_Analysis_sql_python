-- find top 10 highest reveue generating products 
select  sub_category,round(sum(sale_price),2) as sales
from sldata
group by  sub_category
order by sales desc
limit 10 ;


-- find top 5 highest selling products in each region
with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from sldata
group by year(order_date),month(order_date)
order by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month




-- for each category which month had highest sales 
WITH cte as (
select category,format(order_date,'yyyyMM') as order_year_month
, sum(sale_price) as sales 
from sldata
group by category,format(order_date,'yyyyMM')
order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1
;


-- which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT sub_category,
           YEAR(order_date) AS order_year,
           SUM(profit) AS total_profit
    FROM sldata
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
           SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
    FROM cte
    GROUP BY sub_category
)
SELECT  sub_category, 
       profit_2022, 
       profit_2023, 
       (profit_2023 - profit_2022) AS profit_growth
FROM cte2
ORDER BY profit_growth DESC
limit 1 ;
