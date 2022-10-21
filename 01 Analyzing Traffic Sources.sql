-- Ex1: Finding Top Traffic Sources
USE mavenfuzzyfactory;
SELECT 
	utm_source, 
    utm_campaign, 
    http_referer, 
	COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;


-- Ex2: Traffic Sources Conversion Rates
SELECT 
	ws.utm_source,
    ws.utm_campaign,
    COUNT(DISTINCT o.order_id) as orderCount,
    COUNT(DISTINCT ws.website_session_id) as sessionCount,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) as convertionRate
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE 
	ws.created_at < '2012-04-12'
GROUP BY
	ws.utm_source,
    ws.utm_campaign;	


-- ex3: Classify single and two items purchased with product_id
SELECT 
	primary_product_id, 
    COUNT(CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS singleItemOrders_count,
    COUNT(CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS twoItemOrders_count
FROM orders
GROUP BY 1;


-- ex4: Traffic source trending by week to check the drop down of gsearch nonbrand 
SELECT 
	MIN(created_at) AS weekStartedAt,
    COUNT( DISTINCT website_session_id) sessionCount
FROM website_sessions ws
WHERE 
	ws.created_at < '2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
    WEEK(created_at);

-- # weekStartedAt, sessionCount
-- 2012-03-19 08:04:16	896
-- 2012-03-25 01:00:54	956
-- 2012-04-01 00:24:09	1152
-- 2012-04-08 00:38:30	983
-- 2012-04-15 00:07:13	621
-- 2012-04-22 00:08:47	594
-- 2012-04-29 00:50:42	681
-- 2012-05-06 01:14:30	399

-- ex5: Conversion Rate from session to order by device type and weeks
WITH _tempCountTbl AS (
	SELECT 
		DATE(MIN(ws.created_at)) weekStartDate,
		COUNT(CASE WHEN device_type = 'desktop' THEN 1 ELSE NULL END) desktopSessionCount,
		COUNT(CASE WHEN device_type = 'mobile' THEN 1 ELSE NULL END) mobileSessionCount,
		COUNT(CASE WHEN device_type = 'desktop' AND order_id IS NOT NULL THEN 1 ELSE NULL END) desktopOrderCount,
		COUNT(CASE WHEN device_type = 'mobile' AND order_id IS NOT NULL THEN 1 ELSE NULL END) mobileOrderCount
	FROM website_sessions ws
		LEFT JOIN orders o
			ON ws.website_session_id = o.website_session_id
	WHERE ws.created_at >= '2012-04-15'
	GROUP BY
		YEAR(ws.created_at),
		WEEK(ws.created_at)
)
SELECT *, 
	desktopOrderCount/desktopSessionCount AS CVR_Desktop,
	mobileOrderCount/mobileSessionCount AS CVR_Mobile
FROM _tempCountTbl
ORDER BY CVR_Desktop, CVR_Mobile DESC;
