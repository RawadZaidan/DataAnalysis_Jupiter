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