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

WITH history AS 
(SELECT season, round, date, home_club_name, away_club_name, aggregate, 
    CASE 
        WHEN home_club_goals > away_club_goals THEN home_club_name
        WHEN home_club_goals < away_club_goals THEN away_club_name
        ELSE 'Draw' 
    END AS Result
FROM premier_league.stg_games 
WHERE (away_club_name = 'Chelsea FC' AND home_club_name = 'Arsenal FC') 
    OR (away_club_name = 'Arsenal FC' AND home_club_name = 'Chelsea FC'))
	

SELECT result AS winner_club,
    CAST((COUNT(result) * 100.0 / (SELECT COUNT(*) FROM history)) AS FLOAT) AS Percentage
FROM history
GROUP BY result;