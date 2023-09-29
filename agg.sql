-- AGG PLAYER GOALS
-- SELECT player.player_name,
-- COUNT(player.player_id) AS player_goals
-- FROM premier_league.stg_games_events events
-- INNER JOIN premier_league.dim_player AS player
-- ON player.player_id = events.player_id
-- WHERE events.type = 'Goals'
-- GROUP BY player.player_id
-- ORDER BY COUNT(player.player_id) DESC


--AGG OCCURANCES BY MINUTE
-- SELECT type,
-- 		minute,
-- 		count(club_id) AS occurances

-- FROM premier_league.stg_games_events
-- GROUP BY type,minute
-- ORDER Bycount(club_id) DESC

SELECT ,*  FROM premier_league.stg_games
ORDER BY season, round