/*
BIG DATA ENGINEERING: ASSIGNMENT 1 - PART 3
*/

USE DATABASE assignment_1;


-- [Q1] What are the 3 most viewed videos for each country in the Gaming category
-- for the trending_date = '2024-04-01'. Order the result by country and the rank
WITH rk_table AS
(
    SELECT
        country,
        title,
        channeltitle,
        view_count,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY view_count DESC) AS rk,
    FROM table_youtube_final
    WHERE 
        category_title = 'Gaming' AND
        trending_date = '2024-04-01'
)
SELECT *
FROM rk_table
WHERE rk <= 3
ORDER BY country, rk;


-- [Q2] For each country, count the number of distinct video with a title containing
-- the word “BTS” (case insensitive) and order the result by count in a descending order
SELECT 
    country,
    COUNT(DISTINCT video_id) AS ct
FROM table_youtube_final
WHERE title ILIKE '%BTS%'
GROUP BY country
ORDER BY ct DESC;


-- [Q3] For each country, year and month (in a single column) and only for the 
-- year 2024, which video is the most viewed and what is its likes_ratio (defined 
-- as the percentage of likes against view_count) truncated to 2 decimals. Order
-- the result by year_month and country.
WITH rk_table_views
AS
(
    SELECT
        ROW_NUMBER() OVER (PARTITION BY country, trending_date ORDER BY view_count DESC) AS rk,
        country,
        trending_date AS year_month,
        title, 
        channeltitle,
        category_title,
        view_count,
        TRUNCATE((likes / NULLIF(view_count, 0)) * 100, 2) AS likes_ratio
    FROM table_youtube_final
    WHERE YEAR(trending_date) = 2024
    ORDER BY year_month, country
)
SELECT 
    country,
    year_month,
    title, 
    channeltitle,
    category_title,
    view_count,
    likes_ratio
FROM rk_table_views
WHERE rk = 1;


-- [Q4] For each country, which category_title has the most distinct videos and 
-- what is its percentage (2 decimals) out of the total distinct number of videos
-- of that country? Only look at the data from 2022. Order the result by 
-- category_title and country.
WITH 
category_table AS
(
    SELECT
        country,
        category_title,
        total_category_video
    FROM
    (
        WITH rk_table AS
        (
            SELECT
                country,
                category_title,
                COUNT(DISTINCT video_id) AS total_category_video
            FROM table_youtube_final
            WHERE YEAR(trending_date) = 2022
            GROUP BY category_title, country
        )
        SELECT 
            ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_category_video DESC) AS rk,
            *
        FROM rk_table
    )
    WHERE rk = 1
    ORDER BY category_title, country
),
country_table AS
(
    SELECT
        country,
        COUNT(DISTINCT video_id) AS total_country_video
    FROM table_youtube_final
    GROUP BY country
)
SELECT 
    t1.country,
    t1.category_title,
    t1.total_category_video,
    t2.total_country_video,
    TRUNCATE(t1.total_category_video / t2.total_country_video * 100, 2) AS percentage
FROM category_table t1
LEFT JOIN country_table t2
ON t1.country = t2.country
;


-- [Q5] Find the video with the longest title and its length (return title and title_length)?
-- [A5] Title: Victor Cibrian x Fuerza Regida x Luis R Conriquez x La Decima Banda - En El Radio Un Cochinero Remix | Length: 100
SELECT
    title,
    LENGTH(title) as title_length
FROM table_youtube_final
GROUP BY title
ORDER BY title_length DESC
LIMIT 1;


-- [Q6] Which channeltitle has produced the most distinct videos and what is this number?
-- [A6] Vijay Television | 2049 distinct videos
SELECT
    channeltitle,
    COUNT(DISTINCT video_id) AS count_distinct_videos
FROM table_youtube_final
GROUP BY channeltitle
ORDER BY count_distinct_videos DESC
LIMIT 1;

