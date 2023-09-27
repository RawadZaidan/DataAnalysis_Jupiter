-- Create the dim_season table
CREATE TABLE IF NOT EXISTS premier_league.dim_season (
    season_id SERIAL PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    league_name VARCHAR(255) -- Specify the length for VARCHAR
);

-- Create an index for season_id
CREATE INDEX IF NOT EXISTS idx_season_id ON premier_league.dim_season(season_id);

-- -- Insert seasons from 2018 to 2023 into the dim_season table
-- INSERT INTO premier_league.dim_season (season_id, start_date, end_date, league_name)
-- VALUES
--     (2018, '2018-08-01', '2019-05-31', 'Premier League'),
--     (2019, '2019-08-01', '2020-05-31', 'Premier League'),
--     (2020, '2020-08-01', '2021-05-31', 'Premier League'),
--     (2021, '2021-08-01', '2022-05-31', 'Premier League'),
--     (2022, '2022-08-01', '2023-05-31', 'Premier League'),
--     (2023, '2023-08-01', '2024-05-31', 'Premier League'); -- Updated end_date for 2023

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

