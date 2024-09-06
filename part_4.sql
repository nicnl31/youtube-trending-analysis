/*
BIG DATA ENGINEERING: ASSIGNMENT 1 - PART 4
*/

USE DATABASE assignment_1;

-- All years in the dataset by trending date
SELECT 
    DISTINCT YEAR(trending_date) AS yr
FROM table_youtube_final
ORDER BY yr;


-- Rank table for LIKES
WITH rank_likes_table
AS
(
    WITH 
    ratio_table AS
    (
        SELECT 
            country,
            category_title,
            YEAR(trending_date) AS trending_year,
            TRUNCATE(likes/NULLIF(view_count, 0)*100, 2) as likes_ratio,
            TRUNCATE(comment_count/NULLIF(view_count, 0)*100, 2) as comments_ratio,
        FROM table_youtube_final
        WHERE category_title NOT IN ('Music', 'Entertainment')
    )
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY country, trending_year ORDER BY likes_ratio DESC) AS rank_likes,
        ROW_NUMBER() OVER (PARTITION BY country, trending_year ORDER BY comments_ratio DESC) AS rank_comments
    FROM ratio_table
    WHERE 
        likes_ratio IS NOT NULL AND
        comments_ratio IS NOT NULL
)
SELECT
    country,
    category_title,
    trending_year,
    likes_ratio,
FROM rank_likes_table
WHERE rank_likes = 1
ORDER BY trending_year ASC, likes_ratio DESC
;


-- Rank table for COMMENTS
WITH rank_comments_table
AS
(
    WITH 
    ratio_table AS
    (
        SELECT 
            country,
            category_title,
            YEAR(trending_date) AS trending_year,
            TRUNCATE(likes/NULLIF(view_count, 0)*100, 2) as likes_ratio,
            TRUNCATE(comment_count/NULLIF(view_count, 0)*100, 2) as comments_ratio,
        FROM table_youtube_final
        WHERE category_title NOT IN ('Music', 'Entertainment')
        -- GROUP BY country, category_title
    )
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY country, trending_year ORDER BY likes_ratio DESC) AS rank_likes,
        ROW_NUMBER() OVER (PARTITION BY country, trending_year ORDER BY comments_ratio DESC) AS rank_comments
    FROM ratio_table
    WHERE 
        likes_ratio IS NOT NULL AND
        comments_ratio IS NOT NULL
)
SELECT
    country,
    category_title,
    trending_year,
    comments_ratio,
FROM rank_comments_table
WHERE rank_comments = 1
ORDER BY trending_year ASC, comments_ratio DESC
;


-- Rank table for VIEW COUNTS
WITH rank_views_table
AS
(
    WITH view_counts_table 
    AS
    (
        SELECT 
            country,
            category_title,
            YEAR(trending_date) AS trending_year,
            view_count
        FROM table_youtube_final
        WHERE category_title NOT IN ('Music', 'Entertainment')
    )
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY country, trending_year ORDER BY view_count DESC) AS rank_views
    FROM view_counts_table
)
SELECT 
    country,
    category_title,
    trending_year,
    view_count
FROM rank_views_table
WHERE rank_views = 1
ORDER BY trending_year ASC, view_count DESC
;
