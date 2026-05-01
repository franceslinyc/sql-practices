-- Spotify Streaming History
-- https://datalemur.com/questions/spotify-streaming-history

-- Step 1
-- Extract the count of song plays from the weekly table

SELECT 
  user_id, 
  song_id, 
  COUNT(song_id) AS song_plays
FROM songs_weekly
WHERE listen_time <= '08/04/2022 23:59:59'
GROUP BY              -- Careful! Every non-aggregated column must be in a GROUP BY. 
  user_id, 
  song_id;

-- Step 2
-- Combine historical streaming and weekly data

SELECT 
  user_id, 
  song_id, 
  song_plays
FROM songs_history
UNION ALL             -- Keep every rows; UNION will remove duplicates
SELECT 
  user_id, 
  song_id, 
  COUNT(song_id) AS song_plays
FROM songs_weekly
WHERE listen_time <= '08/04/2022 23:59:59'
GROUP BY 
  user_id, 
  song_id;

-- Step 3

WITH tmp AS (
  SELECT 
    user_id, 
    song_id, 
    song_plays
  FROM songs_history
  UNION ALL
  SELECT 
    user_id, 
    song_id, 
    COUNT(song_id) AS song_plays
  FROM songs_weekly
  WHERE listen_time <= '08/04/2022 23:59:59'
  GROUP BY user_id, song_id
)

-- Step 4
-- Find the cumulative count of song plays

WITH history AS (
  SELECT 
    user_id, 
    song_id, 
    song_plays
  FROM songs_history
  UNION ALL
  SELECT 
    user_id, 
    song_id, 
    COUNT(song_id) AS song_plays
  FROM songs_weekly
  WHERE listen_time <= '08/04/2022 23:59:59'
  GROUP BY user_id, song_id -- Careful! Every non-aggregated column must be in a GROUP BY. 
)
SELECT 
  user_id, 
  song_id, 
  SUM(song_plays) AS song_count
FROM history
GROUP BY                    -- Again! Every non-aggregated column must be in a GROUP BY. 
  user_id, 
  song_id
ORDER BY song_count DESC;