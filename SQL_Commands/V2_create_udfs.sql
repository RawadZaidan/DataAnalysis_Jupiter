-- get rental duration function
CREATE OR REPLACE FUNCTION dw_reporting.get_rental_duration(rental_date TIMESTAMP, return_date TIMESTAMP)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(AGE FROM (return_date - rental_date));
END;
$$LANGUAGE plpgsql;

-- get film category name
CREATE OR REPLACE FUNCTION dw_reporting.get_film_category(film_id INTEGER)
RETURNS TEXT AS $$
DECLARE 
    category_name TEXT;
BEGIN
    SELECT 
        categ.name INTO category_name
    FROM public.film_category film_category
    INNER JOIN public.category AS categ
    ON categ.category_id = film_category.category_id
    WHERE film_category.film_id = film_id
    LIMIT 1;
    RETURN category_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION premier_league.home_club_winning_percentage(home_club_name TEXT)

WITH history AS (
    SELECT season, round, date, home_club_name, away_club_name, aggregate, 
        CASE 
            WHEN home_club_goals > away_club_goals THEN home_club_name
            WHEN home_club_goals < away_club_goals THEN away_club_name
            ELSE 'Draw' 
        END AS Result
    FROM premier_league.stg_games 
    WHERE (away_club_name = 'Chelsea FC' AND home_club_name = 'Arsenal FC') 
        OR (away_club_name = 'Arsenal FC' AND home_club_name = 'Chelsea FC')
)

SELECT
    CAST(COUNT(CASE WHEN result = 'Chelsea FC' THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FLOAT) AS "Home_Club Win Percentage",
    CAST(COUNT(CASE WHEN result = 'Arsenal FC' THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FLOAT) AS "Away_Club Win Percentage",
    CAST(COUNT(CASE WHEN result = 'Draw' THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FLOAT) AS "Draw Percentage"
FROM history

CREATE OR REPLACE FUNCTION premier_league.get_match_results_percentage(
    home_club_name TEXT,
    away_club_name TEXT
)
RETURNS TABLE (
    home_club_name TEXT,
    away_club_name TEXT,
    home_win_percent FLOAT,
    away_win_percent FLOAT,
    draw_percent FLOAT
) AS $$
BEGIN
    RETURN QUERY (
        WITH history AS (
            SELECT season, round, date, home_club_name, away_club_name, aggregate, 
                CASE 
                    WHEN home_club_goals > away_club_goals THEN home_club_name
                    WHEN home_club_goals < away_club_goals THEN away_club_name
                    ELSE 'Draw' 
                END AS Result
            FROM premier_league.stg_games 
            WHERE (away_club_name = away_club_name AND home_club_name = home_club_name) 
                OR (away_club_name = home_club_name AND home_club_name = away_club_name)
        )
        SELECT
            home_club_name AS "Home Team",
            away_club_name AS "Away Team",
            CAST(COUNT(CASE WHEN result = home_club_name THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FLOAT) AS "Home Team Win Percentage",
            CAST(COUNT(CASE WHEN result = away_club_name THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FLOAT) AS "Away Team Win Percentage",
            CAST(COUNT(CASE WHEN result = 'Draw' THEN 1 ELSE NULL END) * 100.0 / COUNT(*) AS FLOAT) AS "Draw Percentage"
        FROM history
    );
END;
$$ LANGUAGE plpgsql;
