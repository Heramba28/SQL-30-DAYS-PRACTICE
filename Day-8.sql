SELECT * FROM stocks;
SELECT * FROM stock_prices;

-- 1. List all companies and their sectors.
SELECT name,sector FROM stocks;

-- 2 Show all stock price records for January 1, 2024.
SELECT * FROM stock_prices
WHERE price_date='2024-01-01';

-- 3 Find the highest closing price recorded across all stocks.
SELECT s.name , MAX(sp.close_price) as cp FROM stocks s
INNER JOIN stock_prices sp
ON s.stock_id=sp.stock_id 
GROUP BY s.name
ORDER BY cp DESC
LIMIT 1;

-- 4 List all IT sector companies and their latest available stock price.
SELECT s.name, sp.close_price, sp.price_date
FROM stocks s
JOIN stock_prices sp ON s.stock_id = sp.stock_id
WHERE s.sector = 'IT'
  AND sp.price_date = (
    SELECT MAX(sp2.price_date)
    FROM stock_prices sp2
    WHERE sp2.stock_id = s.stock_id
  );

-- 5 Calculate the daily price change (close - open) for each stock.
SELECt s.name , close_price - open_price 
FROM stocks s
JOIN stock_prices sp ON s.stock_id = sp.stock_id;

-- 6 Find the total traded volume per company.
SELECT s.name,SUM(volume)
FROM stocks s
JOIN stock_prices sp ON s.stock_id = sp.stock_id
GROUP BY s.name;

-- 7 Show which stock had the largest single-day price gain.
SELECT s.name, sp.price_date, 
       sp.open_price, sp.close_price, 
       (sp.close_price - sp.open_price) AS gain
FROM stocks s
JOIN stock_prices sp ON s.stock_id = sp.stock_id
ORDER BY gain DESC
LIMIT 1;

-- 8 Display all companies whose stock price decreased on any day.
SELECT s.name, sp.price_date, 
       sp.open_price, sp.close_price, 
       (sp.close_price - sp.open_price) AS gain
FROM stocks s
JOIN stock_prices sp ON s.stock_id = sp.stock_id
WHERE (sp.close_price - sp.open_price) < 0;

-- 9 Find the average closing price for each company.
SELECT s.name , AVG(sp.close_price)
FROM stocks s
JOIN stock_prices sp ON s.stock_id = sp.stock_id
GROUP BY s.name;

-- 10 Show each company’s stock performance (price change) over two days.
WITH ranked_prices AS (
  SELECT 
    s.name,
    sp.price_date,
    sp.close_price,
    ROW_NUMBER() OVER (PARTITION BY s.stock_id ORDER BY sp.price_date) AS rn
  FROM stocks s
  JOIN stock_prices sp ON s.stock_id = sp.stock_id
)
SELECT 
  p1.name,
  p1.close_price AS day1_price,
  p2.close_price AS day2_price,
  (p2.close_price - p1.close_price) AS price_change
FROM ranked_prices p1
JOIN ranked_prices p2 
  ON p1.name = p2.name AND p1.rn = 1 AND p2.rn = 2;

