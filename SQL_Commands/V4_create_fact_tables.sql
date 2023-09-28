---TODO
CREATE TABLE IF NOT EXISTS premier_league.fact_competition_results (
    competition_id INT,
    season_id INT PRIMARY KEY REFERENCES premier_league.dim_season(season_id),
    champion_team_id INT REFERENCES premier_league.dim_club(club_id),
    runner_up_team_id INT REFERENCES premier_league.dim_club(club_id),
    top_scorer_player_id INT  REFERENCES premier_league.dim_player(player_id)
);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_competition_results(season_id);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_competition_results(champion_team_id);

INSERT INTO premier_league.fact_competition_results(
	competition_id,
	season_id,
	champion_team_id,
	runner_up_team_id,
	top_scorer_player_id
)
SELECT
    1 AS competition_id,  
    ds.season_id,
    c1.club_id AS champion_team_id,  
    c2.club_id AS runner_up_team_id, 
    dp.player_id AS top_scorer_player_id 
FROM
    dim_season ds
    JOIN dim_club c1 ON (some_condition_for_champion)
    JOIN dim_club c2 ON (some_condition_for_runner_up)
    JOIN dim_player dp ON (some_condition_for_top_scorer);
select * from premier_league.dim_club
---------------------------------------------------
--DONE tested
CREATE TABLE IF NOT EXISTS premier_league.fact_game_results (
    match_id INT PRIMARY KEY REFERENCES premier_league.dim_match(match_id),
    score VARCHAR,
    home_team_goals INT,
    away_team_goals INT,
    home_possession FLOAT,
    away_possession FLOAT,
    home_shots INT,
    away_shots INT,
    home_shots_on_target INT,
    away_shots_on_target INT,
    home_fouls INT,
    away_fouls INT,
    home_yellow_cards INT,
    away_yellow_cards INT,
    home_red_cards INT,
    away_red_cards INT
    -- extra_time
    -- attendance
);
CREATE INDEX IF NOT EXISTS idx_match_id ON premier_league.fact_game_results(match_id);

INSERT INTO premier_league.fact_game_results
   (match_id,score,home_team_goals, away_team_goals,home_possession,away_possession,
   home_shots,away_shots,home_shots_on_target,away_shots_on_target,home_fouls,away_fouls,
   home_yellow_cards,away_yellow_cards,
   home_red_cards,away_red_cards)
SELECT
	src_web_stats.match_id,
	CONCAT(src_web_stats.home_score,'-',src_web_stats.away_score) as score,
	src_web_stats.home_score,
	src_web_stats.away_score,
	src_web_stats.home_possession,
	src_web_stats.away_possession,
	src_web_stats.home_shots,
	src_web_stats.away_shots,
	src_web_stats.home_shots_on_target,
	src_web_stats.away_shots_on_target,
	src_web_stats.home_fouls_conceded,
	src_web_stats.away_fouls_conceded,
	src_web_stats.home_yellow_cards,
	src_web_stats.away_yellow_cards,
	src_web_stats.home_red_cards,
	src_web_stats.away_red_cards
FROM premier_league.stg_web_stats AS src_web_stats
ON CONFLICT (match_id)
DO UPDATE SET 
    match_id=excluded.match_id,
	score=excluded.score,
	home_team_goals=excluded.home_team_goals,
	away_team_goals=excluded.away_team_goals,
	home_possession=excluded.home_possession,
	away_possession=excluded.away_possession,
	home_shots=excluded.home_shots,
	away_shots=excluded.away_shots,
	home_shots_on_target=excluded.home_shots_on_target,
	away_shots_on_target=excluded.away_shots_on_target,
	home_fouls=excluded.home_fouls,
	away_fouls=excluded.away_fouls,
	home_yellow_cards=excluded.home_yellow_cards,
	away_yellow_cards=excluded.away_yellow_cards,
	home_red_cards=excluded.home_red_cards,
	away_red_cards=excluded.away_red_cards
-------
--TO CHECK 
-- Create the fact_player_performance table
CREATE TABLE IF NOT EXISTS premier_league.fact_player_performance (
    match_date DATE,
    match_id INT  ,
    player_id INT  ,
    goals_scored INT,
    assists INT,
    minutes_played INT,
    yellow_cards INT,
    red_cards INT
);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(match_id);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(player_id);

-- must run these 3 lines of code before inserting to allow to have conflict on both match_id and player_id

-- ALTER TABLE premier_league.fact_player_performance
-- ADD CONSTRAINT unique_match_player
-- UNIQUE (match_id, player_id);

-- -- Insert data into the fact_player_performance table
INSERT INTO premier_league.fact_player_performance (
	match_date,
	match_id,
	player_id, 
	goals_scored,
	assists,  
	minutes_played,
	yellow_cards,
	red_cards)
SELECT
    DATE(scr_games.date),
    scr_games.game_id,
    scr_appearances.player_id,
    scr_appearances.goals,
    scr_appearances.assists,
    scr_appearances.minutes_played,
    scr_appearances.yellow_cards,
    scr_appearances.red_cards
FROM
  premier_league.stg_games AS scr_games
JOIN
   premier_league.stg_appearances AS scr_appearances
ON
    scr_games.game_id = scr_appearances.game_id
ON CONFLICT (match_id, player_id)
DO UPDATE SET
    match_date = excluded.match_date,
    match_id = excluded.match_id, -- Corrected column name
    goals_scored = excluded.goals_scored,
    assists = excluded.assists,
    minutes_played = excluded.minutes_played,
    yellow_cards = excluded.yellow_cards, -- Corrected column name
    red_cards = excluded.red_cards; -- Corrected column name
