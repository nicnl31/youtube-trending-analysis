# YouTube Trending Videos Analysis

This is a university project where I used SQL and Tableau to analyse a YouTube trending videos dataset. 
This demo project demonstrates my skills in using SQL and Tableau to analyse a dataset and draw insights,
as well as building a data model using a data lakehouse approach.

# Structure of this Repository

.

├── part_1.sql

├── part_2.sql

├── part_3.sql

├── part_4.sql

├── tableau_workbook.twbx

└── visualisations

    ├── P3 Trending Videos by Country.png
    
    ├── P3 count_videos_bts.png
    
    ├── P3 max_view_counts.png
    
    ├── P3_distinct_videos.png
    
    ├── P4 Category by Comments ratio.png
    
    ├── P4 Category by Likes ratio.png
    
    └── P4 Category by View counts.png
    

# The Data

The data covers trending YouTube videos in ten countries: Great Britain, Japan, South
Korea, India, Mexico, Brazil, Canada, Germany, France, and the United States. The data
spans 5 years, from 2020 to 2024, and includes various statistics such as video
information, channel information, published date and trending date, category, and
performance statistics (likes, comments, views). There is also a separate meta-dataset
about each country’s available video categories and their IDs.
The full dataset is available online via Kaggle: https://www.kaggle.com/datasets/rsrishav/youtube-trending-video-dataset

# The Setup

I store the raw category and trending datasets on Azure Cloud blob storage, then connect it to Snowflake
to execute SQL queries from there. I built a data lakehouse model, where:

- Data lake: raw data is imported into external tables in Snowflake, where they are in a semi-structured format
- Data warehouse: Internal tables are then created using a schema-on-read approach, where data processing is also applied

BI software, such as Tableau/Jupyter, can then connect directly to Snowflake to query from its tables and generate visuals.

![datalakehouse](https://github.com/user-attachments/assets/706108e1-8cfd-45d6-ba02-f3568661a11a)

# License
This software is bound by the MIT License.
