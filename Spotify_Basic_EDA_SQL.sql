--Dataset: My Spotify streaming history 2020-2021
--Source: From Spotify 
--Queried using: SQLite 3

Select * from spotify_streaming_history;

--How many Duplicates values are there in dataset?

Select count(*) - count( DISTINCT(track_id)) as duplicates 
FROM spotify_streaming_history;

--What Are the total number of songs In the data set ?

SELECT count(track_id) as total_songs_played
FROM spotify_streaming_history;

--converting duration in milliseconds to minutes

/*SELECT track_name, duration_ms/60000
FROM spotify_streaming_history;*/

ALTER TABLE spotify_streaming_history
ADD COLUMN duration_min float;

UPDATE spotify_streaming_history
SET duration_min = duration_ms/60000

ALTER TABLE spotify_streaming_history
DROP COLUMN duration_ms;

--What is the average duration of songs_played ?

SELECT track_name, 
avg(duration_min) as avg_duration
FROM spotify_streaming_history
GROUP by track_name
ORDER by avg(duration_min) DESC;

--top 10 popular songs based on the number of times songs were clicked and played

SELECT track_name, 
count(track_id) as popularity
FROM spotify_streaming_history
GROUP by track_name
ORDER by count(track_id) DESC LIMIT 10;

--What is the average danceability of the top 12 most popular songs?

SELECT track_name,
count(track_id) as popular_songs,
avg(danceability) as avg_danceability
FROM spotify_streaming_history
GROUP by track_name
ORDER by count(track_id) DESC LIMIT 12;

--What is the average energy by artist? 
Select 
artist_name,
round(avg(energy),3) as average_energy
FROM
spotify_streaming_history
group by artist_name
order by avg(energy) DESC;

--Who are the top 10 artists who has most contribution of songs in the dataset ?

SELECT artist_name,
count( distinct( track_id)) as songs_contribution
FROM spotify_streaming_history
GROUP by artist_name
ORDER by count( distinct( track_id)) DESC LIMIT 10;

--Calculate the average popularity (number of times their songs were clicked and played) for the artists in the Spotify data table. 
--Then, for every artist with number of times of 35 or above, show their name, their average song count, and label them as a “Top Star."

WITH popularity_cte as
(
SELECT 
artist_name,
count(track_id) as popularity_songscount
FROM spotify_streaming_history
GROUP by artist_name
)

SELECT artist_name,
avg(popularity_songscount) average_no_times_songs_plyed ,
"Top Star" as Tag
FROM popularity_cte
GROUP by artist_name
HAVING avg(popularity_songscount) > 100
ORDER by avg(popularity_songscount) DESC;

--popularity of the artists based on the total amount of time spent listening to their songs
SELECT 
artist_name,
sum(duration_min) as total_time
FROM spotify_streaming_history
GROUP by artist_name
ORDER by sum(duration_min) DESC;

--What is the total amount of time spent listening to music each day?

SELECT 
day,
CASE WHEN sum(duration_min)> 60 THEN round(((sum(duration_min))/60),2) ELSE sum(duration_min) end as total_time,
CASE WHEN sum(duration_min)> 60 THEN "hr" ELSE "mins" END as hr_mins
FROM spotify_streaming_history
GROUP by day
ORDER by sum(duration_min) DESC;

--Which categories of emotions in songs are popular among the tracks listened?
-- Feature called "valence" is known as Emotion. It is measured between 0.0 to 1.0
SELECT 
CASE WHEN valence >= 0.8 THEN 'Happy songs'
WHEN valence >= 0.5 and valence < 0.8 THEN 'Neutral emotion'
ELSE 'sad songs' 
END as Emotion_category,
count(DISTINCT(track_id)) as total_songs
FROM spotify_streaming_history
GROUP by 1
ORDER by count(DISTINCT(track_id)) DESC;

--Categories of emotions in Top 10 (maximum no of times played) songs played
SELECT 
track_name,
count(track_id) as top_10_songs,
CASE WHEN valence >= 0.8 THEN 'Energetic songs'
WHEN valence >= 0.5 and valence < 0.8 THEN 'Neutral emotion'
ELSE 'melody' 
END as Emotion_category
 FROM spotify_streaming_history
GROUP by 1
ORDER by 2 DESC
LIMIT 10;

--What is the preferred music duration?
WITH duration_groups_cte as 
(
SELECT
track_name,
CASE WHEN duration_min BETWEEN 1.0 and 2.9 THEN "1.0- 2.9"
WHEN duration_min BETWEEN 3.0 and 5.0 THEN "3.0- 5.0"
WHEN duration_min > 5.0 THEN "> 5.0"
ELSE "< 1.0"
END as duration_groups
FROM spotify_streaming_history
ORDER by 2 DESC
)
SELECT 
duration_groups,
count(duration_groups) as preferred_duration
FROM duration_groups_cte
GROUP by 1
ORDER by 2 DESC

--which artist released the longest song?

SELECT 

DISTINCT(track_name),
artist_name,
duration_min
FROM spotify_streaming_history
ORDER by duration_min DESC