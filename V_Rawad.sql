--seasons dim table 
CREATE TABLE IF NOT EXISTS premier_league.dim_season (
    season_id SERIAL PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    league_name VARCHAR
);
CREATE INDEX IF NOT EXISTS idx_season_id ON premier_league.dim_season(season_id);

-- Insert seasons from 2018 to 2023 into the dim_season table
INSERT INTO premier_league.dim_season (season_id, start_date, end_date, league_name)
VALUES
    (2018,'2018-08-01', '2019-05-31', 'Premier League'),
    (2019,'2019-08-01', '2020-05-31', 'Premier League'),
    (2020,'2020-08-01', '2021-05-31', 'Premier League'),
    (2021,'2021-08-01', '2022-05-31', 'Premier League'),
    (2022,'2022-08-01', '2023-05-31', 'Premier League'),
    (2023,'2022-08-01', '2023-05-31', 'Premier League');

----------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS premier_league.fact_player_performance (
    match_date DATE,
    match_id INT REFERENCES premier_league.dim_match(match_id),
    player_id INT PRIMARY KEY REFERENCES premier_league.dim_player(player_id),
    goals_scored INT,
    assists INT,
    shots_on_goal INT,
    minutes_played INT,
    yellow_cards INT,
    red_cards INT,
);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(match_id);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(player_id);

INSERT INTO premier_league.fact_player_performance (match_id, player_id, goals_scored, assists, shots_on_goal,
    passing_accuracy, dribbles_completed, tackles_made, minutes_played, yellow_card, red_card)
SELECT
	DATE(scr_games.date) as match_date,
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
    game_id = excluded.game_id,
    goals_scored = excluded.goals_scored,
    assists = excluded.assists,
    shots_on_goal = excluded.shots_on_goal,
    minutes_played = excluded.minutes_played,
    yellow_card = excluded.yellow_cards,
    red_card = excluded.red_cards;