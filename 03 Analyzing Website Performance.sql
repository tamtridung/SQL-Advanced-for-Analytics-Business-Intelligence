USE mavenfuzzyfactory;
-- ----------------------------------
-- EX1: FINDING THE TOP WEBSITE PAGE
-- ----------------------------------
SELECT 	
	pageview_url,
    COUNT(ws.website_session_id) as sessionsCount
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE
	ws.created_at <= '2012-06-09'
GROUP BY 
	pageview_url
ORDER BY 2 DESC;

-- ----------------------------------
-- EX2: FINDING THE TOP ENTRY PAGES
-- Step 1: find the first pageview for each session
-- Step 2: find the url the customer saw on that first pageview
-- ----------------------------------
CREATE TEMPORARY TABLE firstPvPerSession
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS firstPV
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT 
	wp.pageview_url,
    COUNT(DISTINCT fpvs.website_session_id) firstHittingPage
FROM 
	website_pageviews wp
LEFT JOIN firstPvPerSession fpvs
	ON wp.website_pageview_id = fpvs.firstPV
GROUP BY
	wp.pageview_url
ORDER BY fpvs.firstPV DESC;

-- ----------------------------------
-- EX3: COMPARING CHANNEL CHARACTERISTICS
-- ----------------------------------
SELECT 
	utm_source,
    COUNT(website_session_id) AS sessionCount,
    COUNT(CASE WHEN device_type = 'mobile' THEN 1 ELSE NULL END) mobileSessions,
    COUNT(CASE WHEN device_type = 'mobile' THEN 1 ELSE NULL END)/COUNT(website_session_id) Pct_mobile
FROM website_sessions
WHERE 
	utm_campaign = 'nonbrand'
	AND created_at BETWEEN '2012-08-22' AND '2012-11-30'
GROUP BY 1
HAVING utm_source IN ('gsearch', 'bsearch');

-- -----------------------------------------------
-- EX4: CROSS-CHANNEL CONVERSION RATE OPTIMIZATION
-- -----------------------------------------------
SELECT 
	ws.device_type,
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS sessionCount,
    COUNT(DISTINCT o.order_id) AS ordersCount,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS CVR
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE 
	utm_campaign = 'nonbrand'
	AND ws.created_at BETWEEN '2012-08-22' AND '2012-09-19'
GROUP BY 1, 2;


-- -----------------------------------------------
-- EX5: CHANNEL PORTFOLIO TRENDS
-- -----------------------------------------------
SELECT 
	DATE(MIN(created_at)) weekStartDate,
    COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN 1 ELSE NULL END) AS G_DtopSessions,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN 1 ELSE NULL END) AS B_DtopSessions,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN 1 ELSE NULL END)/
			COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN 1 ELSE NULL END) AS BperG_dtop,
    COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN 1 ELSE NULL END) AS G_mobSessions,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN 1 ELSE NULL END) AS B_mobSessions,
    COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN 1 ELSE NULL END)/
			COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN 1 ELSE NULL END) AS BperG_mob
FROM website_sessions
WHERE 
	utm_campaign = 'nonbrand'
	AND created_at BETWEEN '2012-11-04' AND '2012-12-22'
GROUP BY
	YEAR(created_at),
    WEEK(created_at);
    
    
-- -----------------------------------------------
-- EX5: CHANNEL PORTFOLIO TRENDS
-- -----------------------------------------------
SELECT 
	YEAR(tb.created_at) yr,
    MONTH(tb.created_at) mth,
    COUNT(CASE WHEN chanelGroup = 'paidNonbrand' THEN 1 ELSE NULL END) AS NonbrandSessions,
    COUNT(CASE WHEN chanelGroup = 'paidBrand' THEN 1 ELSE NULL END) AS brandSessions,
    COUNT(CASE WHEN chanelGroup = 'paidBrand' THEN 1 ELSE NULL END)/
		COUNT(CASE WHEN chanelGroup = 'paidNonbrand' THEN 1 ELSE NULL END) as brand_per_NonBrand,
	COUNT(CASE WHEN chanelGroup = 'directTypeIn' THEN 1 ELSE NULL END) AS directSession,
	COUNT(CASE WHEN chanelGroup = 'directTypeIn' THEN 1 ELSE NULL END)/
		COUNT(CASE WHEN chanelGroup = 'paidNonbrand' THEN 1 ELSE NULL END) as direct_per_NonBrand,
	COUNT(CASE WHEN chanelGroup = 'organicSearch' THEN 1 ELSE NULL END) AS organicSession,
	COUNT(CASE WHEN chanelGroup = 'organicSearch' THEN 1 ELSE NULL END)/
		COUNT(CASE WHEN chanelGroup = 'paidNonbrand' THEN 1 ELSE NULL END) as organic_per_NonBrand
FROM 
	(
	SELECT *, 
		CASE
			WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organicSearch'
			WHEN utm_campaign = 'nonbrand' THEN 'paidNonbrand'
			WHEN utm_campaign = 'brand' THEN 'paidBrand'
			WHEN utm_source IS NULL AND http_referer IS NULL THEN 'directTypeIn'
		END AS chanelGroup
	FROM website_sessions
    ) tb
GROUP BY 1, 2;
    



