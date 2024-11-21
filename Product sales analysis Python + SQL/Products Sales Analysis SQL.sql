use orders;

CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,            -- Assuming order_id is an integer and unique
    order_date DATE,                     -- Date for the order
    ship_mode VARCHAR(50),               -- Mode of shipment (e.g., Standard, Express)
    segment VARCHAR(50),                 -- Customer segment (e.g., Consumer, Corporate)
    country VARCHAR(100),                -- Country where the order is placed
    city VARCHAR(100),                   -- City of the customer
    state VARCHAR(100),                  -- State of the customer (if applicable)
    postal_code VARCHAR(20),             -- Postal code of the shipping address
    region VARCHAR(50),                  -- Region (e.g., North, South)
    category VARCHAR(100),               -- Category of the product (e.g., Electronics, Furniture)
    sub_category VARCHAR(100),           -- Sub-category of the product
    product_id varchar(50),                      -- Product ID (foreign key if needed)
    quantity INT,                        -- Quantity of the product ordered
    discount DECIMAL(5, 2),              -- Discount applied (percentage, e.g., 10.00%)
    sales_price DECIMAL(10, 2),          -- Sales price per unit of the product
    profit DECIMAL(10, 2)                -- Profit from the sale (e.g., sales_price - cost_price)
);

-- Find top 10 revenue genrating products
SELECT top10 product_id, SUM(sales_price) sales FROM df_orders 
GROUP BY 1
ORDER BY sales DESC
LIMIT 10;	

-- Find the top 5 Selling products in each region
WITH ranked_sales AS (
    SELECT 
        product_id, 
        region, 
        SUM(sales_price * quantity) AS selling_pro, 
        DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(sales_price * quantity) DESC) AS ran
    FROM df_orders
    GROUP BY product_id, region
)
SELECT 
    product_id, 
    region, 
    selling_pro, 
    ran
FROM ranked_sales
WHERE ran <= 5;

-- Find month over month Growth comparison bet 2022  and 2023 sales eg. 2022 and 2023
WITH CTE as (SELECT	 YEAR(order_date) years, month(order_date) months, SUM(sales_price) sales FROM df_orders
GROUP BY 1,2
ORDER BY 1 DESC)
SELECT months,
	SUM(CASE WHEN years = 2022 then sales else 0 end) as Sales_2022,
    SUM(case When years = 2023 then sales else 0  end) as Sales_2023
    FROM CTE
GROUP BY months;

-- for each Category which months has higest sales
with cte as (
Select category, FORMAT(order_date, 'yyyy-MM') as order_year_month , Sum(sales_price) as sales from df_orders 
Group by category, FORMAT(order_date, 'yyyy-MM')
)

SELECT * FROM (
SELECT *,
row_number() OVER(partition by category order by sales desc) as rn

from cte) a
WHERE rn = 1;

-- which sub category  had  higest  growth  by profit  in 2023 compair to 2022
WITH cte as (SELECT sub_category, YEAR(order_date) years, SUM(sales_price) sales
FROM df_orders
GROUP BY 1,2),

cte2 as (SELECT sub_category,
	SUM(CASE WHEN years = 2022 then sales else 0 end) as sales_2022,
    SUM(CASE when years  = 2023 then sales else 0 end) as sales_2023
FROM cte
GROUP BY 1) 
 
 SELECT *, (sales_2023 - sales_2022) growth FROM cte2
 ORDER BY growth DESC;