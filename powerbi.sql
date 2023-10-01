WITH home_team_select AS (
SELECT club_id,
		club_name AS home_team_name,
		stadium_name
	FROM premier_league.dim_club
), 
away_team_select AS (
SELECT club_id,
		club_name AS away_team_name,
		stadium_name
	FROM premier_league.dim_club
),
clean_set AS (
SELECT * FROM premier_league.dim_match m
INNER JOIN home_team_select c
ON m.home_team_id = c.club_id
INNER JOIN away_team_select p
ON m.away_team_id = p.club_id
ORDER BY match_date
	)

SELECT * FROM clean_set

-- SELECT * FROM premier_league.stg_web_stats

-- SELECT CAST(web.date AS DATE),* FROM premier_league.stg_web_stats web
-- INNER JOIN clean_set 
-- ON clean_set.home_team_name = web.home_team
-- AND clean_set.away_team_name = web.away_team


---

SELECT *
FROM 
  premier_league.stg_games_events events
INNER JOIN 
  premier_league.dim_player AS player
ON 
  player.player_id = events.player_id
INNER JOIN 
  premier_league.stg_games AS match
ON 
  match.game_id = events.game_id
WHERE 
  events.type = 'Goals'