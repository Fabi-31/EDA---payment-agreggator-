-- Your task is to clean the data 
-- and perform exploratory analysis :
-- to understand customer behavior,
-- sales trends, 
-- and product performance. 


-- 1. Cleaning the data

-- 1. Remove dplicates
-- 2. Standardize the Data 
-- 3. Null values or blank values 
-- 4. Remove any columns or rows

-- 1. Remove dplicates

CREATE TABLE transactions_off
LIKE transactions;

SELECT *
FROM transactions_off;

INSERT transactions_off
SELECT *
FROM transactions;

SELECT *
FROM transactions_off LIMIT 10;

SELECT transaction_id, COUNT(*) AS cnt
FROM transactions_off
GROUP BY transaction_id
HAVING COUNT(*) > 1;




SET SQL_SAFE_UPDATES = 0;



WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id, customer_id, transaction_date, amount,
                            payment_method, merchant_category, location, device_type,
                            status, is_fraud
           ) AS rn
    FROM transactions_off
)
DELETE FROM transactions_off
WHERE transaction_id IN (
    SELECT transaction_id FROM duplicate_cte WHERE rn > 1
);


-- 2. Standardize the Data 

-- Normalize casing and trim whitespace
UPDATE transactions_off
SET payment_method = TRIM(LOWER(payment_method)),
    merchant_category = TRIM(LOWER(merchant_category)),
    device_type = TRIM(LOWER(device_type)),
    status = TRIM(LOWER(status)),
    location = TRIM(LOWER(location));

-- STEP 4: Handle nulls and blanks
-- Example: Set missing device types to 'unknown'
UPDATE transactions_off
SET device_type = 'unknown'
WHERE device_type IS NULL OR device_type = '';

-- STEP 5: Validate amounts (remove or log negative values)
DELETE FROM transactions_off
WHERE amount <= 0;


SELECT *
FROM device_type
WHERE transaction_date IS NOT NULL;


SELECT *
FROM transactions_off
WHERE device_type = '';


-- the columns where the device type is not notified ...









-- EDA process
-- 1) to understand customer behavior,


SELECT customer_id, COUNT(*) AS total_transactions
FROM transactions_off
GROUP BY customer_id
ORDER BY total_transactions DESC
LIMIT 10;


-- We can see how many transactions a customer made 

SELECT COUNT(*) AS clients, total_transactions 
FROM (
SELECT customer_id, COUNT(*) AS total_transactions
FROM transactions_off
GROUP BY customer_id
) t
GROUP BY total_transactions;

-- we can see the repartition by frequence ;  it seems like 44 clients made 4 transactions; 19 clients made 7 transactions...
-- this let us know how many clients made an x amount of transactions 





-- Identify sales trends

-- evolution of sales per month

SELECT DATE_FORMAT(transaction_date, "%Y-%m") AS month, 
       SUM(amount) AS total_sales
FROM transactions_off
GROUP BY month
ORDER BY month
LIMIT 0, 1000;  

--  for may 2023 we can see the the amount of total sales is '601767546' ( But in CFA ? or in Euros ??)
-- there is only the month of may in the data 

-- let's see the busiest day for transactions 

SELECT DAYNAME(transaction_date) AS day, COUNT(*) AS transactions 
FROM transactions_off
GROUP BY day
ORDER BY transactions DESC; 

-- we have the amount of transactions per day, Monday is the day with the most transactions =342. People are most likeley to make a transactions on monday


SELECT MAX(amount) AS max_amount
FROM transactions_off; 
-- the biggest transaction 

SELECT *
FROM transactions_off
ORDER BY amount DESC
LIMIT 1; 
-- on 05/27 is the day with the biggest transaction 

SELECT transaction_date, COUNT(*) AS nb_transactions
FROM transactions_off
GROUP BY transaction_date
ORDER BY nb_transactions DESC
LIMIT 0, 1000;
-- 05/29 is the date with the most transactions, the date with the most activity

SELECT 
  YEAR(transaction_date) AS year,
  WEEK(transaction_date, 1) AS week_number, 
  COUNT(*) AS nb_transactions 
  FROM transactions_off
  GROUP BY year, week_number 
  ORDER BY nb_transactions DESC
  LIMIT 1;
  -- the 21 st week of the year is the best one; from 05/22 to 05/28... 



-- product performance : 

-- the products or the merchant category with the most sales 

SELECT merchant_category, COUNT(*) AS total_sales, SUM(amount) AS total_revenue 
FROM transactions_off
GROUP BY merchant_category
ORDER BY total_sales DESC;
-- we have 7 merchant category: Eectronics with the most sales 628 and revenue '188321874' , then clothing, groceries, furniture, restauran, pharmacy, Jewerly   


-- the payment method the most used 

SELECT payment_method, COUNT(*) AS usage_count 
FROM transactions_off
GROUP BY payment_method
ORDER BY usage_count DESC;
-- Afrimoney is the payment method the most used with 502 total usage.



-- the city with the most sales to see where most of the users are from 

SELECT location, COUNT(*) AS total_transactions, SUM(amount) AS total_sales 
FROM transactions_off
GROUP BY location
ORDER BY total_sales DESC; 
-- the city with the most sales, clients the most actif, is Abidjan with 526 total transaction 


-- the device type the most used 

SELECT device_type, COUNT(*) AS usage_count
FROM transactions_off 
GROUP BY device_type 
ORDER BY usage_count DESC;
-- the device the most used is the mobile.

-- the status 
SELECT status, COUNT(*) AS total 
FROM transactions_off
GROUP BY status
ORDER BY total DESC;
-- ON 2000 transactions there is 1714 transactions completed, 186 transactions failed, 100 pending. 
-- We can ask ourselves why are they not all completed ?

SELECT COUNT(*) AS total_transactions 
FROM transactions_off;



-- how many frauds and where they come from ?

SELECT COUNT(*) AS total_frauds
FROM transactions_off
WHERE is_fraud = 1;
-- There is 50 frauds 

SELECT location, COUNT(*) AS frauds
FROM transactions_off
WHERE is_fraud = 1
GROUP BY location 
ORDER BY frauds DESC; 
-- Abidjan is the location with the most frauds : 16 















