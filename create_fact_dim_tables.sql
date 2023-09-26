
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

INSERT INTO premier_league.dim_player
   (player_id, player_name, nationality, date_of_birth, position, price, team_id)
SELECT 
   src_player.player_id,
   src_player.name,
   src_player.country_of_citizenship,
   src_player.date_of_birth::DATE,
   src_player.position,
   src_player.market_value_in_eur,
   src_player.current_club_id
FROM premier_league.stg_players AS src_player
ON CONFLICT (player_id)
DO UPDATE SET 
   player_name = excluded.player_name,
   nationality = excluded.nationality,
   date_of_birth = excluded.date_of_birth,
   position = excluded.position,
   price = excluded.price,
   team_id = excluded.team_id;

# excluded key word allows you is used within the context of the 'on conflict' clause when performing an INSERT
#allows you to reference the values that were in the attempted insertion but were excluded due to a conflict

CREATE TABLE IF NOT EXISTS premier_league.dim_match (
    match_id SERIAL PRIMARY KEY,
    match_date DATE,
    home_team_id INT REFERENCES premier_league.dim_team(team_id),
    away_team_id INT REFERENCES premier_league.dim_team(team_id),
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
