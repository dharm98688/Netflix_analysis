--NETFLIX ANALYSIS

DROP TABLE if exists netflix;
CREATE TABLE netflix
(
	show_id varchar(10),
	type VARCHAR(50),
	title varchar(150),
	director varchar(300),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
)
select * from netflix

SELECT 
	COUNT(*) AS total_content
FROM netflix

SELECT 
	DISTINCT TYPE
FROM netflix

--Count the number of movies vs tv shows
SELECT 
	TYPE,
	COUNT(*) AS total_content
FROM netflix
GROUP BY TYPE

--2. Most common ratings for movies and TV SHOWS
WITH RATING_COUNT AS
(
	SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RANKEDRATING AS
(
	SELECT
		type,
		rating,
		rating_count,
		RANK() OVER(PARTITION BY type ORDER BY rating_count DESC) AS rank
	FROM RATING_COUNT
)
SELECT
	type,
	rating as frequent_rating
FROM RANKEDRATING
WHERE
	rank = 1

--3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE
	type = 'Movie'
	AND
	release_year = 2021

--4.Find the top 5 countries with the most content on Netflix
SELECT 
	STRING_TO_ARRAY(country, ',') AS new_country,
	COUNT(*)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5

--5. Identify the longest movie
SELECT * FROM netflix
WHERE type= 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1):: INT DESC

--6.Find content added in the last 5 years
SELECT * FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY')>= CURRENT_DATE-INTERVAL '5 years'

--7.Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix
WHERE
--	director = 'Rajiv Chilaka'
	director ILIKE '%Rajiv Chilaka%'

--8. List all the tv shows which have more than 5 seasons
SELECT * FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1) :: numeric >5

--9.Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')),
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC

--10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
	country,
	release_year,
	COUNT(show_id) as release_content,
	ROUND(
	COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric *100
	,2)
	AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country,2
ORDER BY avg_release DESC

--11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in ILIKE '%Documentaries%'

--12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year >EXTRACT(YEAR FROM CURRENT_DATE)-10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
	COUNT(*)--used to count the number of occurrences of each unique actor from the casts
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
/*
15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT 
	category,
	type,
	count(*) as content_count
FROM
(
	SELECT
		*,
		CASE
			WHEN description ILIKE '%KILL%' OR description ILIKE '%VOILENCE%' THEN 'BAD'
			ELSE 'GOOD'
		END as category
	FROM netflix
) as categorised_content
GROUP BY 1,2
ORDER BY 2
	
