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
   scr_clubs.name,
   scr_clubs.stadium_name
FROM premier_league.stg_clubs as scr_clubs
ON CONFLICT (club_id)
DO UPDATE SET 
   club_id = excluded.club_id,
   club_name = excluded.club_name,
   stadium_name = excluded.stadium_name


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
