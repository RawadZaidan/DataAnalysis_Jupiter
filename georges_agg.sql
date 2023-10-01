--- GOALS PER TEAM

-- TOTAL GOALS HOME TEAMS
WITH HOME_TEAM_GOALS AS
(
SELECT
	home_team,
	SUM(home_score) AS goals
FROM premier_league.stg_web_stats
GROUP BY home_team
),
-- TOTAL GOALS AWAY TEAMS
AWAY_TEAM_GOALS AS
(
SELECT
	away_team,
	SUM(away_score) AS goals
FROM premier_league.stg_web_stats
GROUP BY away_team
)

SELECT
	home_team as team,
	HOME_TEAM_GOALS.goals+AWAY_TEAM_GOALS.goals as total_goals
FROM HOME_TEAM_GOALS
INNER JOIN AWAY_TEAM_GOALS
ON HOME_TEAM_GOALS.home_team=AWAY_TEAM_GOALS.away_team
ORDER BY HOME_TEAM_GOALS.goals+AWAY_TEAM_GOALS.goals DESC

-- GOALS CONCEIDED PER TEAM
-- TOTAL GOALS CONCEIDED HOME TEAMS
WITH HOME_TEAM_GOALS AS
(
SELECT
	home_team,
	SUM(away_score) AS goals_conceided
FROM premier_league.stg_web_stats
-- WHERE EXTRACT(YEAR FROM date)=2023
GROUP BY home_team

-- WHERE EXTRACT (YEAR FROM date)>'2023'
),
-- TOTAL GOALS CONCEIDED AWAY TEAMS
AWAY_TEAM_GOALS AS
(
SELECT
	away_team,
	SUM(home_score) AS goals_conceided
FROM premier_league.stg_web_stats
-- WHERE EXTRACT(YEAR FROM date)=2023
GROUP BY away_team
)

-- GOALS CONCEIDED PER TEAM
SELECT
	home_team as team,
	HOME_TEAM_GOALS.goals_conceided+AWAY_TEAM_GOALS.goals_conceided as total_goals_conceided
FROM HOME_TEAM_GOALS
INNER JOIN AWAY_TEAM_GOALS
ON HOME_TEAM_GOALS.home_team=AWAY_TEAM_GOALS.away_team
ORDER BY HOME_TEAM_GOALS.goals_conceided+AWAY_TEAM_GOALS.goals_conceided DESC



--- View for team analysis 

CREATE OR REPLACE VIEW premier_league.team_stats_per_date AS
SELECT
	premier_league.fact_game_results.away_team_name AS team_name,
	premier_league.fact_game_results.home_team_name AS opponent_name,
	premier_league.fact_game_results.away_team_goals AS goals,
	premier_league.fact_game_results.home_team_goals AS goals_conceided,
	premier_league.fact_game_results.away_possession AS possession,
	premier_league.fact_game_results.away_shots_on_target AS shots_target,
	premier_league.fact_game_results.away_yellow_cards AS yellow_cards,
	premier_league.fact_game_results.away_red_cards AS red_cards,
	premier_league.fact_game_results.match_date,
	premier_league.fact_game_results.match_id,
	premier_league.fact_rolling_points_standing.season
FROM premier_league.fact_game_results
INNER JOIN premier_league.fact_rolling_points_standing
ON premier_league.fact_game_results.match_id=premier_league.fact_rolling_points_standing.match_id
UNION
SELECT
	premier_league.fact_game_results.home_team_name,
	premier_league.fact_game_results.away_team_name AS opponent_name,
	premier_league.fact_game_results.home_team_goals AS goals,
	premier_league.fact_game_results.away_team_goals AS goals_conceided,
	premier_league.fact_game_results.home_possession,
	premier_league.fact_game_results.home_shots_on_target,
	premier_league.fact_game_results.home_yellow_cards,
	premier_league.fact_game_results.home_red_cards,
	premier_league.fact_game_results.match_date,
	premier_league.fact_game_results.match_id,
	premier_league.fact_rolling_points_standing.season
FROM premier_league.fact_game_results
INNER JOIN premier_league.fact_rolling_points_standing
ON premier_league.fact_game_results.match_id=premier_league.fact_rolling_points_standing.match_id