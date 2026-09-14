--Advanced SQL project -Spotify Datasets
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify(
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


--EDA
SELECT COUNT(*) FROM spotify;
SELECT COUNT(DISTINCT artist) FROM spotify;
SELECT COUNT(DISTINCT album ) FROM spotify;
SELECT DISTINCT  album_type FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;


DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT most_played_on  FROM spotify;

---  ------------------------
--Date analysis - Easy Category
-- ----------------------------

--Retrieve the names of all tracks that have more than 1 billion streams.
SELECT 
     *
FROM spotify
WHERE stream > 1000000000;


--List all albums along with their respective artists.
SELECT 
	DISTINCT artist,
	album 
FROM spotify

-- Get the total number of comments for tracks where licensed = TRUE.
    SELECT 
	SUM(comments) as total_comments
	FROM spotify
   WHERE licensed = 'true'
   
-- Find all tracks that belong to the album type single.
SELECT 
*
FROM spotify
WHERE album_type = 'single';

-- Count the total number of tracks by each artist.
SELECT
  artist,
 COUNT(track) as total_track
 FROM spotify
 GROUP BY 1
 ORDER BY 2 

--- -- -------------
-- Medium Level
---- --------------

-- Calculate the average danceability of tracks in each album.

SELECT 
     album,
	 track,
	 AVG( danceability) AS avg_dancebility
FROM  spotify
GROUP BY 1,2
order by 3 DESC
-- Find the top 5 tracks with the highest energy values.
SELECT 
track,
MAX(energy)
FROM spotify
GROUP BY 1,2
ORDER BY 2 DESC
LIMIT 5
-- List all tracks along with their views and likes where official_video = TRUE.
SELECT 
		track, 
		SUM(views) AS total_view,
		SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;


-- For each album, calculate the total views of all associated tracks.
SELECT 
   DISTINCT album,
   SUM(views) as total_views
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;
-- Retrieve the track names that have been streamed on Spotify more than YouTube.

-- COALESE ARE USE TO REPLACE NULL WITH 0
-- <> IS NOT EQUAL TO
SELECT *
FROM
(SELECT
   track,
   COALESCE (SUM(CASE WHEN most_played_on ='Youtube'THEN stream END),0 )AS streamed_on_youtube,
   COALESCE (SUM(CASE WHEN most_played_on ='Spotify'THEN stream END),0) AS streamed_on_spotify
 FROM spotify  
 GROUP BY 1) AS t1

 WHERE 
 streamed_on_spotify > streamed_on_youtube
 AND streamed_on_youtube <> 0;

----------- -----------
 ----Advanced Level
---------------------------

-- Find the top 3 most-viewed tracks for each artist using window functions.
SELECT * 
FROM
(SELECT
   artist,
   track,
   sum(views) as total_views,
   DENSE_RANK() OVER (PARTITION BY artist ORDER BY sum(views) DESC ) AS rank
 FROM spotify
 GROUP BY 1,2
 ORDER BY 1 , 3 DESC) AS t1
WHERE 
    rank <= 3;


-- Write a query to find tracks where the liveness score is above the average.
SELECT  
artist,
track,
liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)


-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH difference_table
as
(
SELECT
 album,
 max(energy) as highest_energy,
 min(energy) as lowest_energy
 FROM spotify
 group by 1)
SELECT 
  album,
  highest_energy,
  lowest_energy,
 ( highest_energy - lowest_energy)  as difference
 FROM difference_table
 ORDER BY 4 DESC
 