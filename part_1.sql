/*
BIG DATA ENGINEERING: ASSIGNMENT 1 - PART 1
*/


-- [1] CREATE DATABASE “assignment_1”
CREATE DATABASE assignment_1;
USE DATABASE assignment_1;


-- [2.1] CREATE STAGE “stage_assignment”
CREATE OR REPLACE STAGE stage_assignment 
URL='azure://nicholasbde.blob.core.windows.net/bde-assignment-1'
CREDENTIALS=(AZURE_SAS_TOKEN='?sv=2022-11-02&ss=b&srt=co&sp=rwdlaciytfx&se=2024-12-31T08:56:10Z&st=2024-08-12T01:56:10Z&spr=https&sig=OP2x0oe6tCd5p8d5ApVSvcQI88yx26G0ttmNpYmb3fw%3D');


-- [2.2] LIST THE DATASETS IN THE STAGE
list @stage_assignment;


-- [3] CREATE EXTERNAL TABLES “ex_table_youtube_trending” AND “ex_table_youtube_category”
-- [3.1] Create CSV file format
CREATE OR REPLACE FILE FORMAT file_format_csv
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"';


-- [3.2] Create external table "ex_table_youtube_trending"
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '.*_youtube_trending_data[.]csv';


-- [3.3] Create external table "ex_table_youtube_category"
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE=JSON)
PATTERN = '.*_category_id.json';


-- [3.4] Query data from "ex_table_youtube_trending"
SELECT
    value:c1::                              VARCHAR AS video_id,
    value:c2::                              VARCHAR AS title,
    value:c3::                              DATE    AS publishedAt,
    value:c4::                              VARCHAR AS channelId,
    value:c5::                              VARCHAR AS channelTitle,
    value:c6::                              VARCHAR AS categoryId,
    value:c7::                              DATE    AS trending_date,
    value:c8::                              INT     AS view_count,
    value:c9::                              INT     AS likes,
    value:c10::                             INT     AS dislikes,
    value:c11::                             INT     AS comment_count,
    SPLIT_PART(metadata$filename, '_', 1):: VARCHAR AS country
FROM assignment_1.public.ex_table_youtube_trending
LIMIT 10;


-- [3.5] Query data from "ex_table_youtube_category"
SELECT 
    SPLIT_PART(metadata$filename, '_', 1):: VARCHAR AS country,
    l.value:id::                            INT     AS categoryId,
    l.value:snippet:title::                 VARCHAR AS category_title,
FROM 
    assignment_1.public.ex_table_youtube_category, 
    LATERAL FLATTEN(value:items) l
LIMIT 10;


-- [3.6] Move "ex_table_youtube_trending" into "table_youtube_trending"
CREATE TABLE table_youtube_trending
AS 
(
    SELECT
        value:c1::                              VARCHAR AS video_id,
        value:c2::                              VARCHAR AS title,
        value:c3::                              DATE    AS publishedAt,
        value:c4::                              VARCHAR AS channelId,
        value:c5::                              VARCHAR AS channelTitle,
        value:c6::                              VARCHAR AS categoryId,
        value:c7::                              DATE    AS trending_date,
        value:c8::                              INT     AS view_count,
        value:c9::                              INT     AS likes,
        value:c10::                             INT     AS dislikes,
        value:c11::                             INT     AS comment_count,
        SPLIT_PART(metadata$filename, '_', 1):: VARCHAR AS country
    FROM assignment_1.public.ex_table_youtube_trending
);


-- [3.7] Move "ex_table_youtube_category" into "table_youtube_category"
CREATE TABLE table_youtube_category
AS
(
    SELECT 
        SPLIT_PART(metadata$filename, '_', 1):: VARCHAR AS country,
        l.value:id::                            INT     AS categoryId,
        l.value:snippet:title::                 VARCHAR AS category_title,
    FROM 
        assignment_1.public.ex_table_youtube_category, 
        LATERAL FLATTEN(value:items) l
);


-- [3.8] Create table "table_youtube_final" by joining "table_youtube_trending" and "table_youtube_category"
CREATE TABLE table_youtube_final
AS
(
    SELECT
        UUID_STRING() as id,
        a.video_id,
        a.title,
        a.publishedat,
        a.channelid,
        a.channeltitle,
        a.categoryid,
        b.category_title,
        a.trending_date,
        a.view_count,
        a.likes,
        a.dislikes,
        a.comment_count,
        a.country
    FROM table_youtube_trending a
    LEFT JOIN table_youtube_category b
    ON 
        a.country = b.country AND
        a.categoryid = b.categoryid
);


-- [3.9] Query created tables
SELECT *
FROM table_youtube_trending
LIMIT 10;

SELECT *
FROM table_youtube_category
LIMIT 10;

SELECT *
FROM table_youtube_final
LIMIT 10;


-- [3.10] Ensure table_youtube_final has 2667041 values
SELECT COUNT(*)
FROM table_youtube_final;

