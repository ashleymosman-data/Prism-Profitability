-- Revenue by year
SELECT EXTRACT(YEAR FROM t.date) AS year, SUM(t.transaction_revenue) AS revenue
FROM `prism-acquire.prism_acquire.sessions` as s
JOIN `prism-acquire.prism_acquire.transactions` as t
ON s.session_id = t.session_id
GROUP BY EXTRACT(YEAR FROM t.date)
ORDER BY year DESC;

--Cost of Goods Sold (COGS)
SELECT EXTRACT(YEAR FROM t.date) as Year, SUM(p.cost_of_item * t.item_quantity) AS COGS
FROM `prism-acquire.prism_acquire.product_costs` AS p
JOIN `prism-acquire.prism_acquire.transactionsanditems` AS t
ON p.item_id = t.item_id
GROUP BY EXTRACT(YEAR FROM t.date)
ORDER BY year DESC;

--Customers at End of Period
SELECT COUNT(DISTINCT user_crm_id) AS customers
FROM `prism-acquire.prism_acquire.users`
WHERE EXTRACT(MONTH FROM latest_purchase_date) IN (10, 11, 12)
  AND EXTRACT(YEAR FROM latest_purchase_date) = 2023;
--New Customers
SELECT COUNT(DISTINCT user_crm_id) AS customers
FROM `prism-acquire.prism_acquire.users`
WHERE EXTRACT(MONTH FROM first_purchase_date) IN (10, 11, 12)
  AND EXTRACT(YEAR FROM first_purchase_date) = 2023;
--Customers at Start of Period
SELECT COUNT(DISTINCT user_crm_id) AS customers
FROM `prism-acquire.prism_acquire.users`
WHERE EXTRACT(MONTH FROM latest_purchase_date) IN (1, 2, 3)
  AND EXTRACT(YEAR FROM latest_purchase_date) = 2022;

--Refund Revenue
SELECT p.return_status, ROUND(SUM(transaction_revenue), 2) AS revenue_lost
FROM `prism_acquire.transactions` AS t
LEFT JOIN `prism_acquire.product_returns` AS p
ON t.transaction_id = p.transaction_id
WHERE p.return_status = 'Refund'
GROUP BY p.return_status;

--Return Quantity by Quarter and Year
SELECT COUNT(transaction_id) AS return_count, return_date
FROM `prism-acquire.prism_acquire.product_returns`
GROUP BY return_date;

--Return and Revenue Lost by Item Main Category
SELECT DISTINCT a.item_main_category, SUM(r.return_quantity) AS return_quantity, SUM(r.return_quantity * l.item_list_price) AS revenue_lost
FROM `prism-acquire.prism_acquire.productattributes` AS a
LEFT JOIN `prism-acquire.prism_acquire.product_returns` AS r
ON a.item_id = r.item_id
LEFT JOIN `prism-acquire.prism_acquire.product_listprices` AS l 
ON a.item_id = l.item_id 
GROUP BY item_main_category
ORDER BY revenue_lost DESC;

--Traffic Overview
SELECT COUNT(DISTINCT CASE WHEN s.user_crm_id IS NULL AND t.user_cookie_id IS NULL THEN s.user_cookie_id END) AS visitors,
      COUNT(DISTINCT CASE WHEN t.user_cookie_id IS NULL THEN s.user_crm_id END) AS members,
      COUNT(DISTINCT t.user_cookie_id) AS customers
FROM `prism_acquire.sessions` AS s
LEFT JOIN `prism_acquire.transactions` AS t
ON s.user_cookie_id = t.user_cookie_id;

--Return on Ad Spend (ROAS)
--Revenue by Traffic Source
SELECT s.traffic_source, SUM(t.transaction_revenue) AS revenue
FROM `prism-acquire.prism_acquire.sessions` AS s
LEFT JOIN `prism-acquire.prism_acquire.transactions` AS t
ON s.user_cookie_id = t.user_cookie_id
WHERE traffic_source = 'google'
  OR traffic_source = 'meta'
  OR traffic_source = 'rtbhouse'
GROUP BY traffic_source;
--Ad Spend
SELECT SUM(google_cost) AS google_ad_spend,
  SUM(meta_cost) AS meta_ad_spend,
  SUM(rtbhouse_cost) AS rtbhouse_ad_spend,
FROM `prism-acquire.prism_acquire.adplatform_data`;

