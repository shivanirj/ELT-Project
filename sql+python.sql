select * from master.df_orders;

-- Top 10 highest generating product-- 
select product_id,sum(sale_price) as sales
from
master.df_orders
group by product_id
order by sales desc
limit 10;

-- Top 5 highest selling product in each region-- 
with cte as (select
region,product_id,sum(sale_price) as sales
from
master.df_orders
group by region,product_id
order by region,sales desc)
select * from
(select *,row_number() over(partition by region order by sales desc) as rn
from
cte) as A
where rn <= 5;

-- --find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023--  
with cte as (select year(order_date) as order_year,month(order_date) as order_month,
round(sum(sale_price),2) as sales
from
master.df_orders
group by order_year,order_month
)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as year_2022,
sum(case when order_year = 2023 then sales else 0 end) as year_2023
 from
 cte
 group by order_month
 order by order_month;
 
 -- for each category which month had highest sales -- 
 with cte as (select category, DATE_FORMAT(order_date, '%Y%m')  AS order_year_month_,
 round(sum(sale_price),2) as sales
 from master.df_orders
 group by category,order_year_month_
 ),
 ctetest as (select * ,
 row_number() over(partition by category order by sales desc) as rn
from
 cte
 order by category,order_year_month_ desc ,sales desc)
 select *
 from 
 ctetest
 where
 rn = 1;
 
 
 -- which sub category had highest growth by profit in 2023 compare to 2022-- 
with cte as (select sub_category,year(order_date) as order_year,
round(sum(sale_price),2) as sales
from
master.df_orders
group by sub_category,order_year
),
cte2 as (select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as year_2022,
sum(case when order_year = 2023 then sales else 0 end) as year_2023
 from
 cte
 group by sub_category)
 select *,round(((year_2023 - year_2022) * 100 /year_2022) ,2)as profit_Percent
 from
 cte2
 order by profit_Percent desc
 limit 1;
 
