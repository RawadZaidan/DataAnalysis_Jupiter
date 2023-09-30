WITH wind AS (
  SELECT
    CASE
      WHEN home_team_goals > away_team_goals THEN home_team_name
      WHEN home_team_goals < away_team_goals THEN away_team_name
      ELSE 'Draw'
    END AS winner,
    *
  FROM premier_league.fact_game_results
  ORDER BY match_id
),
new_wind AS (
  SELECT
    CASE
      WHEN SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '38' THEN 2018
      WHEN SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '46' THEN 2019
      WHEN SUBSTRING(CAST(match_id AS TEXT), 1, 2) IN ('58', '59') THEN 2020
      WHEN SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '66' THEN 2021
      WHEN SUBSTRING(CAST(match_id AS TEXT), 0, 3) IN ('74', '75') THEN 2022
      WHEN SUBSTRING(CAST(match_id AS TEXT), 0, 3) = '93' THEN 2023
    END AS season,
    *
  FROM wind
  WHERE home_team_name = 'Manchester City' OR away_team_name = 'Manchester City'
),
points_selected AS (
  SELECT
    CASE
      WHEN winner = 'Manchester City' THEN 3
      WHEN winner = 'Draw' THEN 1
      ELSE 0
    END AS points_selected_team,
    *
  FROM new_wind
--   WHERE season = 2018
)

SELECT
  SUM(points_selected_team) OVER (PARTITION BY season ORDER BY match_id) AS running_points_total,
  *
FROM points_selected;
