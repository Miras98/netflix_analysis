# Netflix Movies/ TV Shows Data Analysis using SQL
![](https://github.com/Miras98/netflix_analysis/blob/056fe3807f83cc83b1b1f7d92ac514a0e86a083b/logo.png)

##Overview
This project involves a comprehensive analysis of netflix movies and tv shows data using SQL.
The goal of this project is to answer business questions and extract valuable insights using this dataset

## Objective
- Analyze the distribution of content type(Movie/TV Show).
- Identify the most common rating for Movies and TV Shows.
- Analyze content based on criteria such as release year, countries, and durations.

## Dataset
-The dataset for this project is sourced from Kaggle datasets: 
[netflix_dataset](https://github.com/Miras98/netflix_analysis/blob/d71c43019df7a826ada67888a2aac92fca28c2d1/netflix_titles.csv)

## Schema
```sql
DROP TABLE IF EXISTS netflix;
create table netflix(
	show_id	VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),	
	director VARCHAR(210),	
	castS VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)

);
```
## Business Problems and Solutions

1- **Count the number of movies and tv shows**
```sql
SELECT 
  type,
  COUNT(*)
FROM netflix
GROUP BY type;
```
2- **Find the most common rating for movies and tv shows**
```sql
SELECT * 
FROM(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
		FROM netflix
		GROUP BY 1,2) t
WHERE ranking = 1;
```
3- **List all movies released in year 2020**
```sql
SELECT *
FROM netflix
WHERE release_year = 2020 AND type= 'Movie';
```
4- **Find the top 5 countries with the most content on netflix**
```sql 
SELECT * 
FROM
(
    SELECT 
       TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```
5- **What is the longest movie**
```sql
SELECT 
title, 
SPLIT_PART(duration, ' ', 1)::INT AS mins
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY mins desc
LIMIT 1;
```
6- **Find content added in the last 5 years**
```sql
SELECT * 
FROM netflix
WHERE CAST(date_added AS DATE) >= CURRENT_DATE - INTERVAL '5 years' ;
```
7- **Find all movies /tv shows by director 'Rajiv Chilaka'**
```sql
SELECT * 
FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%';
```
8- **List all TV shows with more tha 5 seasons**
```sql
SELECT * 
FROM netflix
WHERE type ='TV Show' 
AND split_part(duration, ' ', 1) :: int > 5;
```
9- **count the number of content items in each genre**
```sql
SELECT
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre ,
COUNT(show_id) AS total_content 
FROM netflix
GROUP BY 1;
```
10- **find each year and the avg number of content release in india on netflix,
return top 5 year with highest avg content release**
```sql
SELECT  
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year ,
COUNT(*) AS yearly_content,
ROUND(COUNT(*):: NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country= 'India'):: NUMERIC * 100,2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5;
```
11- **List all movies that are documentaries**
```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries%' 
AND type ='Movie';
```
12- **Find all content without a director**
```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```
13- **Find how many movies actor 'salman khan' appeared in last 10 years**
```sql
SELECT * 
FROM netflix
WHERE country = 'India' 
AND casts LIKE '%Salman Khan%'
AND release_year >= EXTRACT(YEAR FROM current_date) - 10;
```
14- **find top 10 actors who appeared in the highest number of movies produced in india**
```sql
SELECT UNNEST(STRING_TO_ARRAY(casts,',')), 
COUNT(*) 
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
ORDER BY COUNT(*) DESC
LIMIT 10;
```
15- **categorize the content based on the presence of the keyword 'kill' or 'violence' as 'bad'a nd anything else as good
, count how many items fall into each category**
```sql
SELECT  
CASE WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
ELSE 'Good'
END AS category,
COUNT(*) AS total_number
FROM netflix
GROUP BY 1;
```
