--DONE tested
CREATE TABLE IF NOT EXISTS premier_league.dim_club (
    club_id SERIAL PRIMARY KEY,
    club_name VARCHAR,
    stadium_name VARCHAR
);
CREATE INDEX IF NOT EXISTS idx_club_id ON premier_league.dim_club(club_id);

INSERT INTO premier_league.dim_club
   (club_id,club_name, stadium_name)
SELECT
   scr_clubs.club_id,
   scr_clubs.name AS club_name,
   scr_clubs.stadium_name
FROM premier_league.stg_clubs as scr_clubs
ON CONFLICT (club_id)
DO UPDATE SET 
   club_id = excluded.club_id,
   club_name = excluded.club_name,
   stadium_name = excluded.stadium_name

---------------------------
--DONE, tested
CREATE TABLE IF NOT EXISTS premier_league.dim_player (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR,
    nationality VARCHAR,
    position VARCHAR,
    price DECIMAL,
    club_id INT REFERENCES premier_league.dim_club(club_id)
);
CREATE INDEX IF NOT EXISTS idx_player_id ON premier_league.dim_player(player_id);
INSERT INTO premier_league.dim_player
   (player_id, player_name, nationality,  position, price, club_id)
SELECT 
   src_player.player_id,
   src_player.name,
   src_player.country_of_citizenship,
   src_player.position,
   src_player.highest_market_value_in_eur,
   src_player.current_club_id
FROM premier_league.stg_players AS src_player
ON CONFLICT (player_id)
DO UPDATE SET 
   player_name = excluded.player_name,
   nationality = excluded.nationality,
   position = excluded.position,
   price = excluded.price,
   club_id = excluded.club_id;

-----------------------------------------------------
--DONE tested
CREATE TABLE IF NOT EXISTS premier_league.dim_match (
    match_id SERIAL PRIMARY KEY,
    match_date DATE,
    home_team_id INT REFERENCES premier_league.dim_club(club_id),
    away_team_id INT REFERENCES premier_league.dim_club(club_id),
    stadium_name VARCHAR,
    referee_name VARCHAR
);

CREATE INDEX IF NOT EXISTS idx_match_id ON premier_league.dim_match(match_id);

INSERT INTO premier_league.dim_match
   (match_id, match_date, home_team_id, away_team_id, stadium_name, referee_name)
SELECT
   scr_games.game_id,
   scr_games.date::DATE,
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
-----------------------------------------
--DONE TESTED 
CREATE TABLE IF NOT EXISTS premier_league.dim_season (
    season_id SERIAL PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    league_name VARCHAR(255) -- Specify the length for VARCHAR
);

-- Create an index for season_id
CREATE INDEX IF NOT EXISTS idx_season_id ON premier_league.dim_season(season_id);

-- Insert seasons from 2018 to 2023 into the dim_season table
INSERT INTO premier_league.dim_season (season_id, start_date, end_date, league_name)
VALUES
    (2018, '2018-08-01', '2019-05-31', 'Premier League'),
    (2019, '2019-08-01', '2020-05-31', 'Premier League'),
    (2020, '2020-08-01', '2021-05-31', 'Premier League'),
    (2021, '2021-08-01', '2022-05-31', 'Premier League'),
    (2022, '2022-08-01', '2023-05-31', 'Premier League'),
    (2023, '2023-08-01', '2024-05-31', 'Premier League');