-- Finding the average number of injuries for each day of week:
-- Ex: Number of injuries for Thursday games:
SELECT COUNT(*) AS total_players
FROM nfl_injuries
WHERE LOWER(day_of_week) = 'thursday'; → 5572
Number of Thursday games:
SELECT COUNT(*) / 2 AS total_thursday_games
FROM (
   SELECT DISTINCT season_year, week, team
   FROM nfl_injuries
   WHERE LOWER(day_of_week) = 'thursday'
) t;

-- Calculate injuries per game pre- and post-bye
WITH injuries_with_bye AS (
   SELECT
       i.team,
       i.season_year,
       i.week,
       b.bye_week,
       COUNT(i.player) AS injuries_this_week
   FROM nfl_injuries i
   JOIN byes b
       ON i.team = b.team
      AND i.season_year = b.season_year
   GROUP BY i.team, i.season_year, i.week, b.bye_week
),
pre_post_summary AS (
   SELECT
       team,
       season_year,
       bye_week,
       SUM(CASE WHEN week < bye_week THEN injuries_this_week ELSE 0 END) AS pre_bye_injuries,
       COUNT(DISTINCT CASE WHEN week < bye_week THEN week END) AS pre_bye_games,
       SUM(CASE WHEN week > bye_week THEN injuries_this_week ELSE 0 END) AS post_bye_injuries,
       COUNT(DISTINCT CASE WHEN week > bye_week THEN week END) AS post_bye_games
   FROM injuries_with_bye
   GROUP BY team, season_year, bye_week
)
SELECT
   team,
   season_year,
   bye_week,
   pre_bye_injuries::FLOAT / NULLIF(pre_bye_games,0) AS injuries_per_game_pre_bye,
   post_bye_injuries::FLOAT / NULLIF(post_bye_games,0) AS injuries_per_game_post_bye
FROM pre_post_summary
ORDER BY season_year, team;

-- Find Average Number of Listed Injuries Per Day Played After Bye 
WITH games_post_bye AS (
   SELECT
       i.team,
       i.season_year,
       i.week,
       i.day_of_week,
       COUNT(i.player) AS injuries_in_game,
       b.bye_week
   FROM nfl_injuries i
   JOIN byes b
       ON i.team = b.team
      AND i.season_year = b.season_year
   WHERE i.week > b.bye_week  -- only games after the bye
   GROUP BY i.team, i.season_year, i.week, i.day_of_week, b.bye_week
)
SELECT
   team,
   day_of_week,
   AVG(injuries_in_game)::NUMERIC(10,2) AS avg_injuries_post_bye,
   COUNT(*) AS games_count_post_bye
FROM games_post_bye
GROUP BY team, day_of_week
ORDER BY team, day_of_week;

