--Georges
CREATE TABLE IF NOT EXISTS premier_league.dim_club (
    club_id SERIAL PRIMARY KEY,
    club_name VARCHAR,
    stadium_name VARCHAR
);
CREATE INDEX IF NOT EXISTS idx_club_id ON premier_league.dim_club(club_id);
--------------------
--DONE BY MAHMOUD
CREATE TABLE IF NOT EXISTS premier_league.dim_player (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR,
    nationality VARCHAR,
    position VARCHAR,
    price DECIMAL,
    club_id INT REFERENCES premier_league.dim_club(club_id)
);
CREATE INDEX IF NOT EXISTS idx_player_id ON premier_league.dim_player(player_id);
--------------------
--DONE BY MAHMOUD
CREATE TABLE IF NOT EXISTS premier_league.dim_match (
    match_id SERIAL PRIMARY KEY,
    match_date DATE,
    home_team_id INT REFERENCES premier_league.dim_club(club_id),
    away_team_id INT REFERENCES premier_league.dim_club(club_id),
    stadium_name VARCHAR,
    referee_name VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_match_id ON premier_league.dim_match(match_id);
--------------------
--Rawad
CREATE TABLE IF NOT EXISTS premier_league.dim_season (
    season_id SERIAL PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    league_name VARCHAR
);
CREATE INDEX IF NOT EXISTS idx_season_id ON premier_league.dim_season(season_id);
--------------------
--Mahmoud
CREATE TABLE IF NOT EXISTS premier_league.dim_competition (
    competition_id TEXT ,
    competition_name VARCHAR,
    country VARCHAR,
    season_id INT PRIMARY KEY  REFERENCES premier_league.dim_season(season_id)
); -- season id is primary key because it's the only unique value
--------------------
--Rawad
CREATE TABLE IF NOT EXISTS premier_league.fact_player_performance (
    match_date DATE,
    match_id INT,
    player_id INT,
    goals_scored INT,
    assists INT,
    minutes_played INT,
    yellow_cards INT,
    red_cards INT
);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(match_id);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_player_performance(player_id);
--------------------
--Georges
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
--------------------
--Mahmoud
CREATE TABLE IF NOT EXISTS premier_league.fact_competition_results (
    competition_id INT,
    season_id INT PRIMARY KEY REFERENCES premier_league.dim_season(season_id),
    champion_team_id INT REFERENCES premier_league.dim_club(club_id),
    runner_up_team_id INT REFERENCES premier_league.dim_club(club_id),
    top_scorer_player_id INT  REFERENCES premier_league.dim_player(player_id)
);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_competition_results(season_id);
CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.fact_competition_results(champion_team_id);
--------------------