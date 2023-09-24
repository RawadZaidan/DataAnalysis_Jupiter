CREATE TABLE IF NOT EXISTS premier_league.dim_team (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR,
    stadium_name VARCHAR,
    city VARCHAR,
    coach_name VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_team_id ON premier_league.dim_team(team_id);

CREATE TABLE IF NOT EXISTS premier_league.dim_player (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR,
    nationality VARCHAR,
    date_of_birth DATE,
    position VARCHAR,
    price DECIMAL(10, 2),
    team_id INT REFERENCES premier_league.dim_team(team_id)
);

CREATE INDEX IF NOT EXISTS idx_player_id ON premier_league.dim_player(player_id);

CREATE TABLE IF NOT EXISTS premier_league.dim_match (
    match_id SERIAL PRIMARY KEY,
    match_date DATE,
    home_team_id INT REFERENCES premier_league.dim_team(team_id),
    away_team_id INT REFERENCES premier_league.dim_team(team_id),
    stadium_name VARCHAR,
    weather_conditions VARCHAR,
    referee_name VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_match_id ON premier_league.dim_match(match_id);

CREATE TABLE IF NOT EXISTS premier_league.dim_season (
    season_id SERIAL PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    league_name VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_season_id ON premier_league.dim_season(season_id);

CREATE TABLE IF NOT EXISTS premier_league.dim_competition (
    competition_id SERIAL PRIMARY KEY,
    competition_name VARCHAR,
    country VARCHAR,
    season_id INT REFERENCES premier_league.dim_season(season_id)
);

CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.dim_competition(competition_id);

CREATE TABLE IF NOT EXISTS premier_league.fact_player_performance (
    match_id INT REFERENCES premier_league.dim_match(match_id),
    player_id INT REFERENCES premier_league.dim_player(player_id),
    goals_scored INT,
    assists INT,
    shots_on_goal INT,
    passing_accuracy DECIMAL(5, 2),
    dribbles_completed INT,
    tackles_made INT,
    minutes_played INT,
    substitutions_in INT,
    substitutions_out INT
);

CREATE TABLE IF NOT EXISTS premier_league.fact_game_results (
    match_id INT REFERENCES premier_league.dim_match(match_id),
    home_team_score INT,
    away_team_score INT,
    home_team_goals INT,
    away_team_goals INT,
    game_duration_minutes INT,
    attendance INT
);
CREATE TABLE IF NOT EXISTS premier_league.fact_competition_results (
    competition_id INT REFERENCES premier_league.dim_competition(competition_id),
    season_id INT REFERENCES premier_league.dim_season(season_id),
    champion_team_id INT REFERENCES premier_league.dim_team(team_id),
    runner_up_team_id INT REFERENCES premier_league.dim_team(team_id),
    top_scorer_player_id INT REFERENCES premier_league.dim_player(player_id),
    top_scorer_goals INT
);
