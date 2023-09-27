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
    match_id INT REFERENCES premier_league.dim_match(match_id),
    player_id INT PRIMARY KEY REFERENCES premier_league.dim_player(player_id),
    goals_scored INT,
    assists INT,
    shots_on_goal INT,
    gk_saves INT,
    passing_accuracy DECIMAL(5, 2),
    dribbles_completed INT,
    tackles_made INT,
    minutes_played INT,
    yellow_card BOOLEAN,
    red_card BOOLEAN,
);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(match_id);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(player_id);

INSERT INTO premier_league.fact_player_performance
   (match_id, player_id, goals_scored, assists, shots_on_goal, saves referee_name)
SELECT
   scr_games.game_id,
   scr_games.date,
   scr_games.home_club_id,
   scr_games.away_club_id,
   scr_games.stadium,
   scr_games.referee 
FROM premier_league.stg_games as scr_games
ON CONFLICT (match_id)
DO UPDATE SET 
   match_id = excluded.match_id,
   match_date = excluded.match_date,
   home_team_id = excluded.home_team_id,
   away_team_id = excluded.away_team_id,
   stadium_name = excluded.stadium_name,
   referee_name = excluded.referee_name;