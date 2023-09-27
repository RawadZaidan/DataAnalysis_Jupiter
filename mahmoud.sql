CREATE TABLE IF NOT EXISTS premier_league.dim_competition (
    competition_id TEXT ,
    competition_name VARCHAR,
    country VARCHAR,
    season_id INT PRIMARY KEY  REFERENCES premier_league.dim_season(season_id)
);

CREATE INDEX IF NOT EXISTS idx_competition_id ON premier_league.dim_competition(season_id);
INSERT INTO premier_league.dim_competition
   (competition_id, competition_name, country, season_id)
VALUES
   ('GB1', 'premier-league', 'England', 2018),
   ('GB1', 'premier-league', 'England', 2019),
   ('GB1', 'premier-league', 'England', 2020),
   ('GB1', 'premier-league', 'England', 2021),
   ('GB1', 'premier-league', 'England', 2022),
   ('GB1', 'premier-league', 'England', 2023);
   
---not done at alll 
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