select count(*)from netflix;

-- count the number of movies and tv shows

select type, count(*)
from netflix
group by type;

-- find the most common rating for movies and tv shows

select * 
from(
	select 
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*) desc) as ranking
		from netflix
		group by 1,2) t
where ranking = 1;

-- list all movies released in year 2020

select *
from netflix
where release_year = 2020 and type= 'Movie';

-- find the top 5 countries with the most content on netflix

select 
TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS new_country,
count(show_id) as total_content
from netflix
group by 1
order by total_content desc
limit 5;

-- what is the longest movie

SELECT title, SPLIT_PART(duration, ' ', 1)::INT as mins
FROM netflix
where type = 'Movie' and duration is not null
order by mins desc
LIMIT 1;

--find content added in the last 5 years
select * from netflix
where cast(date_added as date) >= current_date - interval '5 years' ;

-- find all movies /tv shows by director 'Rajiv Chilaka'

select * from netflix 
where director like '%Rajiv Chilaka%';

-- list all TV shows with more tha 5 seasons
select * from netflix
where type ='TV Show' 
and split_part(duration, ' ', 1) :: int > 5;

-- count the number of content items in each genre

select unnest(string_to_array(listed_in,',')) as genre ,
count(show_id) as total_content 
from netflix
group by 1;

-- find each year and the avg number of content release in india on netflix
-- return top 5 year with highest avg content release

--steps:
--get each year from the date_Added
-- filter country to india
-- count(*) to get total content and group by yrear
-- to get the avg i neeed to find total number of contents in india and divide the count(*) of each year by this number

select  extract(year from to_date(date_added, 'Month DD, YYYY')) as year ,
count(*) yearly_content,
round(count(*):: numeric / (select count(*) from netflix where country= 'India'):: numeric * 100,2) as avg_content_per_year
from netflix
where country = 'India'
group by 1
order by 3 desc
limit 5;

-- list all movies that are documentaries

select * from netflix
where listed_in like '%Documentaries%' and type ='Movie';

-- find all content without a director
select * from netflix
where director is null;

-- find how many movies actor 'salman khan' appeared in last 10 years

select * from netflix
where country = 'India' and casts like '%Salman Khan%'
and release_year >= extract(year from current_date) -10;

--find top 10 actors who appeared in the highest number of movies produced in india

select unnest(string_to_array(casts,',')), 
count(*) top_10_actors
from netflix
where country ilike '%india'
group by 1
order by top_10_Actors desc
limit 10;

-- categorize the content based on the presence of the keyword 'kill' or 'violence'
-- in the description field, label these as 'bad'a nd anything else as good
-- count how many items fall into each category

select  
case when description like '%kill%' or description like '%violence%' then 'bad'
else 'good'
end as category,
count(*) as total_number
from netflix
group by 1;
