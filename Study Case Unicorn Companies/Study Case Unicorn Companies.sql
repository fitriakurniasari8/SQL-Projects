SELECT * FROM unicorn_companies;
SELECT * FROM unicorn_dates;
SELECT * FROM unicorn_funding;
SELECT * FROM unicorn_industries;

--No 1
--Which continent has the most unicorns? 
--Source table: unicorn_companies
SELECT 
	continent, 
	COUNT(continent) as total_company 
FROM unicorn_companies
GROUP BY 1
ORDER BY 2 DESC;

--No 2
--Which countries have more than 100 unicorns?
--Source table: unicorn_companies
SELECT 
	country, 
	COUNT(company_id) as total_unicorn 
FROM unicorn_companies
GROUP BY 1
HAVING COUNT(company_id) > 100;

--No 3
--Which is the largest industry based on total funding? What is the average valuation?
--Source table: unicorn_industries, unicorn_funding
SELECT
	industry,
	SUM(funding) as total_funding,
	ROUND(AVG(valuation),0) as average_of_valuation
FROM unicorn_industries i
JOIN unicorn_funding f
ON i.company_id = f.company_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--No 4
--Based on the answer of number 3, for Fintech industry, how many companies have joined as unicorns each year in the 2016-2022 range?--Source table: unicorn_companies, unicorn_industries, unicorn_date
SELECT
	EXTRACT(YEAR FROM d.date_joined) as year,
	COUNT(d.company_id) as total_company
FROM unicorn_industries i
JOIN unicorn_dates d
ON i.company_id = d.company_id
WHERE industry = 'Fintech' AND EXTRACT(YEAR FROM d.date_joined) BETWEEN 2016 AND 2022
GROUP BY 1;

--No 5A
--Show detailed company data (company name, city of origin, country and continent of origin) along with its industry and valuation.
--Which country does the company with the largest valuation come from and what is its industry?
SELECT
	company, city, country, continent, industry, valuation
FROM unicorn_companies s
JOIN unicorn_industries i
ON s.company_id = i.company_id
JOIN unicorn_funding f
ON s.company_id = f.company_id
WHERE valuation = (SELECT max(valuation) FROM unicorn_funding);


--No 5B
--How about Indonesia? What company has the biggest valuation in Indonesia?
--Source table: unicorn_companies, unicorn_industries, unicorn_funding
SELECT
	company, city, country, continent, industry, valuation
FROM unicorn_companies s
JOIN unicorn_industries i
ON s.company_id = i.company_id
JOIN unicorn_funding f
ON s.company_id = f.company_id
WHERE country = 'Indonesia'
ORDER BY valuation DESC
LIMIT 1;

--No 6
--How old was the oldest company when it merged to become a unicorn company? Which country does the company come from?
--Source table: unicorn_companies, unicorn_dates
SELECT
	company,
	country,
	(EXTRACT(YEAR FROM date_joined) - year_founded) as age_at_joining
FROM unicorn_companies s
JOIN unicorn_dates d
ON s.company_id = d.company_id
ORDER BY 3 DESC
LIMIT 1;


--No 7
--For companies founded between 1960 and 2000 (upper and lower bounds enter the range),
--How old was the oldest company when it merged to become a unicorn company (date_joined)? Which country does the company come from?
--Source table: unicorn_companies, unicorn_dates
WITH age AS (
SELECT
	company,
	country,
	(EXTRACT(YEAR FROM date_joined) - year_founded) as age_at_joining,
	EXTRACT(MONTH FROM date_joined) as month_joined
FROM unicorn_companies s
	JOIN unicorn_dates d
	ON s.company_id = d.company_id
WHERE year_founded BETWEEN 1960 AND 2000
ORDER BY 3 DESC
LIMIT 1)
SELECT company, country, age_at_joining
FROM age
ORDER BY age_at_joining DESC, month_joined ASC;

--No 8
--How many companies are financed by at least one investor with the name 'venture'?
SELECT
	COUNT(company_id)
FROM unicorn_funding
WHERE lOWER(select_investors) like '%venture%';

--How many companies are financed by at least one investor with the name:
--Ventures
--Capital
--Partners
--Hint: Use LIKE and CASE WHEN inside COUNT DISTINCT
SELECT
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%venture%' THEN company_id END) AS investor_venture,
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%capital%' THEN company_id END) AS investor_capital,
	COUNT(DISTINCT CASE WHEN LOWER(select_investors) LIKE '%partner%' THEN company_id END) AS investor_partner
FROM unicorn_funding; 

--No 9
--In Indonesia there are many startups engaged in logistics services. How many logistics startups are unicorns in Asia?
--How many logistics startups are unicorns in Indonesia?
--Hint: Use DISTINCT and CASE WHEN to calculate the total logistics companies in Indonesia
--Source table: unicorn_companies, unicorn_industries
SELECT 
	COUNT(DISTINCT(i.company_id)) AS total_Asia_logistics,
  	COUNT(DISTINCT CASE WHEN country like '%Indonesia%' THEN country END) AS total_Indonesia_logistics
FROM unicorn_companies s
	JOIN unicorn_industries i 
	ON s.company_id = i.company_id
WHERE industry like '%logistic%'
and continent like '%Asia%';


--No 10 (Bonus)
--In Asia, there are three countries with the highest number of unicorns. 
--Show the number of unicorns in each industry and country of origin in Asia, with the exception of these three countries.
--Sort by industry, number of companies (decreasing), and country of origin.
--Source table: unicorn_companies, unicorn_industries
WITH top3_asia AS (
SELECT
	country,
	COUNT(s.company_id) as total_unicorn
FROM unicorn_companies s
WHERE continent = 'Asia'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3) 
SELECT 
	industry,
	country,
	COUNT(DISTINCT s.company_id) as total_unicorn
FROM unicorn_companies s
	JOIN unicorn_industries i
	ON s.company_id = i.company_id
WHERE country NOT IN (SELECT country FROM top3_asia)
AND continent = 'Asia'
GROUP BY 1,2
ORDER BY 3 DESC, 1,2;


--No 11 (Bonus)
--The United States, China and India are the three countries with the most total unicorns.
--Is there an industry that doesn't have unicorns originating in India? Anything?
--Source table: unicorn_industries, unicorn_companies
SELECT
	DISTINCT industry 
FROM unicorn_industries i
WHERE i.industry NOT IN (
	SELECT
		DISTINCT industry 
	FROM unicorn_companies s
		JOIN unicorn_industries i1 
		ON s.company_id = i1.company_id 
	WHERE s.country = 'India'
);

--No 12 (Bonus)
--Find the three industries that have the most unicorns in 2019-2021 and 
--Displays the number of unicorns and their average valuation (in billions) in each year.
--Source table: unicorn_industries, unicorn_dates, unicorn_funding
WITH top_3 AS (
SELECT
	i.industry,
	COUNT(DISTINCT i.company_id)
FROM unicorn_industries i 
	INNER JOIN unicorn_dates d 
	ON i.company_id = d.company_id 
WHERE 
	EXTRACT(YEAR FROM d.date_joined) IN (2019,2020,2021) 
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
)
SELECT
	i.industry,
	EXTRACT(YEAR FROM d.date_joined) AS year_joined,
	COUNT(DISTINCT i.company_id) AS total_company,
	ROUND(AVG(f.valuation)/1000000000,2) AS avg_valuation_billion
FROM unicorn_industries i 
INNER JOIN unicorn_funding f 
	ON i.company_id = f.company_id
INNER JOIN (SELECT * FROM unicorn_dates WHERE EXTRACT(YEAR FROM date_joined) IN (2019,2020,2021)) d
	ON i.company_id = d.company_id
WHERE i.industry IN (SELECT industry FROM top_3)
GROUP BY 1,2
ORDER BY 1,2 DESC;

--No 13 (Bonus)
--Which country has the most unicorns (as question number 1) and what is the percentage proportion?
--Source table: unicorn_companies
WITH country_level AS (
SELECT
	s.country,
	COUNT(DISTINCT s.company_id) AS total_per_country
FROM unicorn_companies s
GROUP BY 1
)
SELECT
	*,
	CONCAT(ROUND((total_per_country / SUM(total_per_country) OVER())*100,2),'%') AS pct_company
FROM country_level
ORDER BY 2 DESC;
-- BACA WINDOWS FUNCTION DARI GOOGLE