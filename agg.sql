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

-- WeakVsStrong result
-- SELECT CASE
--         WHEN home_club_position > away_club_position
-- 		AND home_club_goals > away_club_goals
-- 		THEN 'Weak team won'
-- 		WHEN home_club_position > away_club_position
-- 		AND home_club_goals < away_club_goals
-- 		THEN 'Strong team won'
-- 		WHEN home_club_position < away_club_position
-- 		AND home_club_goals > away_club_goals
-- 		THEN 'Strong team won'
-- 		WHEN home_club_position < away_club_position
-- 		AND home_club_goals < away_club_goals
-- 		THEN 'Weak team won'
--         ELSE 'Draw'
--     END AS winner,
-- *  FROM premier_league.stg_games
-- ORDER BY season, round

--TEAM WINNING CHANCE
WITH history AS 
(SELECT season, round, date, home_club_name, away_club_name, aggregate, 
    CASE 
        WHEN home_club_goals > away_club_goals THEN home_club_name
        WHEN home_club_goals < away_club_goals THEN away_club_name
        ELSE 'Draw' 
    END AS Result
FROM premier_league.stg_games 
WHERE (away_club_name = 'Chelsea FC' AND home_club_name = 'Arsenal FC') 
    OR (away_club_name = 'Arsenal FC' AND home_club_name = 'Chelsea FC'))
	
SELECT result,
		COUNT(result)
FROM history
GROUP BY result
