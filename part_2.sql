/*
BIG DATA ENGINEERING: ASSIGNMENT 1 - PART 2
*/
USE DATABASE assignment_1;


-- [Q1] In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?
-- [A1] Comedy. It has 2 records in each country.
SELECT 
    country,
    category_title,
    COUNT(*) AS count_category
FROM table_youtube_category
GROUP BY country, category_title
HAVING COUNT(*) > 1;


-- [Q2] In “table_youtube_category” which category_title only appears in one country?
-- [A2] Nonprofits & Activism
SELECT
    category_title,
    COUNT(country) AS count_country
FROM table_youtube_category
GROUP BY category_title
HAVING COUNT(country) = 1;


-- [Q3] In “table_youtube_final”, what is the categoryid of the missing category_titles?
-- [A3] 29
SELECT DISTINCT categoryid
FROM table_youtube_final
WHERE category_title IS NULL;


-- [Q4] Update the table_youtube_final to replace the NULL values in category_title with the answer from the previous question
-- [A4] 1683 rows updated
-- Query 1: Find the category name that has categoryid 29, which is 'Nonprofits & Activism'
SELECT
    category_title
FROM table_youtube_category
WHERE categoryid = 29;

-- Query 2: Update null records
UPDATE table_youtube_final
SET category_title = 'Nonprofits & Activism'
WHERE categoryid = 29;

-- Query 3: Double check that the table is updated by rerunning query in Q3
SELECT DISTINCT categoryid
FROM table_youtube_final
WHERE category_title IS NULL;


-- [Q5] In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)?
-- [A5] Kala Official Teaser | Tovino Thomas | Rohith V S | Juvis Productions | Adventure Company
SELECT DISTINCT title
FROM table_youtube_final
WHERE channeltitle IS NULL;


-- [Q6] Delete from “table_youtube_final“, any record with video_id = “#NAME?”
-- [A6] 32081 rows deleted
-- Query 1: Update 
DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';

-- Query 2: Double check that the table is updated
SELECT COUNT(*)
FROM table_youtube_final
WHERE video_id = '#NAME?';


-- [Q7] Create a new table called “table_youtube_duplicates”  containing only the “bad” duplicates by using the row_number() function
-- [A7] Table "table_youtube_duplicates" contains 37466 records
-- Query 1: Construct a table of all videos that are duplicates, including their originals
SELECT 
    ROW_NUMBER() OVER (PARTITION BY video_id, country, trending_date ORDER BY view_count DESC) AS row_num,
    id,
    video_id,
    country,
    trending_date,
    view_count,
    likes,
    dislikes,
    comment_count
FROM table_youtube_final
WHERE (video_id, country, trending_date) IN
(
    SELECT video_id, country, trending_date
    FROM table_youtube_final 
    GROUP BY video_id, country, trending_date
    HAVING COUNT(trending_date) > 1
);

-- Query 2: Using query 1 table to select from, grab all distinct ID's where the corresponding row_num is greater than 1, indicating duplicates.
-- The subquery only includes the id and row_num columns compared to that in query 1, because those are all that are needed.
SELECT DISTINCT id
FROM 
(
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY video_id, country, trending_date ORDER BY view_count DESC) AS row_num,
        id
    FROM table_youtube_final
    WHERE (video_id, country, trending_date) IN
    (
        SELECT video_id, country, trending_date
        FROM table_youtube_final 
        GROUP BY video_id, country, trending_date
        HAVING COUNT(trending_date) > 1
    )
)
WHERE row_num > 1;

-- Query 3: Create table_youtube_duplicates containing only the bad duplicates
CREATE TABLE table_youtube_duplicates
AS
(
    SELECT *
    FROM table_youtube_final
    WHERE id IN 
    (
        SELECT DISTINCT id
        FROM 
        (
            SELECT 
                ROW_NUMBER() OVER (PARTITION BY video_id, country, trending_date ORDER BY view_count DESC) AS row_num,
                id
            FROM table_youtube_final
            WHERE (video_id, country, trending_date) IN
            (
                SELECT video_id, country, trending_date
                FROM table_youtube_final 
                GROUP BY video_id, country, trending_date
                HAVING COUNT(trending_date) > 1
            )
        )
        WHERE row_num > 1
    )
)
;

-- Query 4: Check that table_youtube_duplicates has exactly 37466 records
SELECT COUNT(*)
FROM table_youtube_duplicates;


-- [Q8] Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”
-- [A8] 37466 rows deleted
-- Query 1: Delete duplicates from "table_youtube_final"
DELETE FROM table_youtube_final
WHERE id IN
(
    SELECT DISTINCT id
    FROM table_youtube_duplicates
);


-- [Q9] Count the number of rows in “table_youtube_final“ and check that it is equal to 2,597,494 rows.
-- [A9] 2597494 rows remaining
SELECT COUNT(*)
FROM table_youtube_final;
