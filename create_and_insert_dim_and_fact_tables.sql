-- dim_club
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
   stadium_name = excluded.stadium_name;
   

--dim_player
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


-- dim_match
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

-- dim_season
CREATE TABLE IF NOT EXISTS premier_league.dim_season (
    season_id SERIAL PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    league_name VARCHAR(255) 
);

CREATE INDEX IF NOT EXISTS idx_season_id ON premier_league.dim_season(season_id);

INSERT INTO premier_league.dim_season (season_id, start_date, end_date, league_name)
VALUES
    (2018, '2018-08-01', '2019-05-31', 'Premier League'),
    (2019, '2019-08-01', '2020-05-31', 'Premier League'),
    (2020, '2020-08-01', '2021-05-31', 'Premier League'),
    (2021, '2021-08-01', '2022-05-31', 'Premier League'),
    (2022, '2022-08-01', '2023-05-31', 'Premier League'),
    (2023, '2023-08-01', '2024-05-31', 'Premier League');

-- fact_game_results -- ADD team names, date 
CREATE TABLE IF NOT EXISTS premier_league.fact_game_results (
    match_id INT PRIMARY KEY,
    match_date DATE,
    home_team_name VARCHAR,
    away_team_name VARCHAR,
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
   (match_id,match_date,home_team_name,away_team_name,score,home_team_goals, away_team_goals,home_possession,away_possession,
   home_shots,away_shots,home_shots_on_target,away_shots_on_target,home_fouls,away_fouls,
   home_yellow_cards,away_yellow_cards,
   home_red_cards,away_red_cards)
SELECT
	src_web_stats.match_id,
   src_web_stats.date,
   src_web_stats.home_team,
   src_web_stats.away_team,
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
   match_date=excluded.match_date,
   home_team_name=excluded.home_team_name,
   away_team_name=excluded.away_team_name,
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
	away_red_cards=excluded.away_red_cards;

-- fact_player_performance
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

ALTER TABLE premier_league.fact_player_performance
ADD CONSTRAINT unique_match_player
UNIQUE (match_id, player_id);

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
    match_id = excluded.match_id, 
    goals_scored = excluded.goals_scored,
    assists = excluded.assists,
    minutes_played = excluded.minutes_played,
    yellow_cards = excluded.yellow_cards, 
    red_cards = excluded.red_cards; 