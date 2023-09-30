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


WITH wind  AS (
SELECT CASE
        WHEN home_team_goals > away_team_goals
		THEN home_team_name
		WHEN home_team_goals < away_team_goals
		THEN away_team_name
        ELSE 'Draw'
    END AS winner,
*  FROM premier_league.fact_game_results
ORDER BY match_id
)

SELECT CASE WHEN 
			SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '38' THEN 2018
			WHEN 
			SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '46' THEN 2019
			WHEN 
			SUBSTRING(CAST(match_id AS TEXT), 1, 2) IN ('58', '59') THEN 2020
			WHEN 
			SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '66' THEN 2021
			WHEN 
			SUBSTRING(CAST(match_id AS TEXT), 0, 3) IN ('74','75') THEN 2022
			WHEN 
			SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '93' THEN 2023
			END AS season,*
FROM wind 

