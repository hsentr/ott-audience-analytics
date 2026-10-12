DECLARE start_date DATE DEFAULT '2025-01-01';
DECLARE end_date DATE DEFAULT '2025-02-28';


-- Entirely fictional data, generated for this portfolio. Not anonymized real data.
-- Run this setup and ONE analysis in the same BigQuery multi-statement script.
-- For queries 01/02/03/05: place their DECLARE statements BEFORE this setup,
-- then append the query's WITH ... SELECT body after the setup.
CREATE TEMP TABLE demo_viewing_events (
 user_id STRING, registered_user_id STRING, is_guest BOOL, view_id STRING,
 view_start_timestamp TIMESTAMP, event_date DATE, publish_timestamp TIMESTAMP,
 series_id STRING, series_title STRING, content_id STRING, content_title STRING,
 watched_seconds FLOAT64, video_seconds FLOAT64, video_type STRING, content_type STRING
);
INSERT INTO demo_viewing_events VALUES
('u01', 'r01', FALSE, 'v01', '2024-12-15 10:00:00', '2024-12-15', '2024-12-01 00:00:00', 's01', 'Atlas Stories', 'e01', 'Atlas Episode 1', 180, 600, 'VOD', 'CONTENT'),
('u01', 'r01', FALSE, 'v02', '2025-01-05 10:00:00', '2025-01-05', '2025-01-01 00:00:00', 's01', 'Atlas Stories', 'e01', 'Atlas Episode 1', 600, 600, 'VOD', 'CONTENT'),
('u01', 'r01', FALSE, 'v03', '2025-01-06 10:00:00', '2025-01-06', '2025-01-01 00:00:00', 's01', 'Atlas Stories', 'e02', 'Atlas Episode 2', 480, 600, 'VOD', 'CONTENT'),
('u02', NULL, TRUE, 'v04', '2025-01-05 11:00:00', '2025-01-05', '2025-01-01 00:00:00', 's01', 'Atlas Stories', 'e01', 'Atlas Episode 1', 120, 600, 'VOD', 'CONTENT'),
('u03', 'r03', FALSE, 'v05', '2025-01-07 10:00:00', '2025-01-07', '2025-01-01 00:00:00', 's01', 'Atlas Stories', 'e01', 'Atlas Episode 1', 300, 600, 'VOD', 'CONTENT'),
('u03', 'r03', FALSE, 'v06', '2025-01-07 11:00:00', '2025-01-07', '2025-01-01 00:00:00', 's01', 'Atlas Stories', 'e02', 'Atlas Episode 2', 450, 600, 'VOD', 'CONTENT'),
('u03', 'r03', FALSE, 'v07', '2025-01-08 10:00:00', '2025-01-08', '2025-01-01 00:00:00', 's02', 'Harbor Science', 'e03', 'Harbor Episode 1', 500, 600, 'VOD', 'CONTENT'),
('u01', 'r01', FALSE, 'v08', '2025-02-02 10:00:00', '2025-02-02', '2025-01-01 00:00:00', 's02', 'Harbor Science', 'e03', 'Harbor Episode 1', 600, 600, 'VOD', 'CONTENT'),
('u04', NULL, TRUE, 'v09', '2025-02-03 10:00:00', '2025-02-03', '2025-02-01 00:00:00', 's01', 'Atlas Stories', 'e02', 'Atlas Episode 2', 90, 600, 'VOD', 'CONTENT'),
('u04', NULL, TRUE, 'v10', '2025-02-04 10:00:00', '2025-02-04', '2025-02-01 00:00:00', 's01', 'Atlas Stories', 'e02', 'Atlas Episode 2', 240, 600, 'VOD', 'CONTENT'),
('u05', NULL, TRUE, 'v11', '2025-01-06 12:00:00', '2025-01-06', '2025-01-01 00:00:00', 's03', 'Live Forum', 'e04', 'Live Forum Session', 300, 600, 'LIVE', 'CONTENT');

INSERT INTO demo_viewing_events VALUES
 ('u03', 'r03', FALSE, 'v12', '2025-01-09 10:00:00', '2025-01-09', '2025-01-01 00:00:00', 's01', 'Atlas Stories', 'e05', 'Atlas Episode 3', 400, 600, 'VOD', 'CONTENT');

CREATE TEMP TABLE demo_paid_spend (
 event_date DATE, series_title STRING, amount_spent FLOAT64, platform STRING, show_title STRING
);
INSERT INTO demo_paid_spend VALUES
 ('2025-01-06', 'Atlas Stories', 80, 'Channel A', 'Atlas Stories'),
 ('2025-01-06', 'Harbor Science', 20, 'Channel A', 'Harbor Science'),
 ('2025-02-03', 'Atlas Stories', 25, 'Channel B', 'Atlas Stories');
CREATE TEMP TABLE demo_country_spend (event_date DATE, country STRING, amount_spent FLOAT64);
INSERT INTO demo_country_spend VALUES
 ('2025-01-06', 'Market A', 70), ('2025-01-06', 'Market B', 30),
 ('2025-02-03', 'Market A', 20), ('2025-02-03', 'Market B', 5);

-- GoogleSQL / BigQuery. Public example with entirely synthetic data.
-- Use the complete examples/run_*.sql script to run one demonstration.
-- No employer data or infrastructure is referenced.
-- Fictional dates are editable; original calculations are retained.
-- Business question: do adjacent episodes share viewers, and who watches often?
-- Measure = viewers of both numbered episodes, regardless of viewing order.
-- Original retention aliases retained; interpret them as audience overlap.
-- Repeat viewing = >=3 distinct selected episodes within the reporting window.
-- Final selected episode has no successor: display comparison as not applicable.
-- Output covers episodes with observed viewers. Release timing/window set exposure.

WITH selected_episodes AS (
  SELECT 'Atlas Episode 1' AS content_title, 1 AS episode_number UNION ALL
  SELECT 'Atlas Episode 2', 2 UNION ALL
  SELECT 'Atlas Episode 3', 3 UNION ALL
  SELECT 'Atlas Episode 4', 4 UNION ALL
  SELECT 'Atlas Episode 5', 5 UNION ALL
  SELECT 'Atlas Episode 6', 6 UNION ALL
  SELECT 'Atlas Episode 7', 7 UNION ALL
  SELECT 'Atlas Episode 8', 8 UNION ALL
  SELECT 'Atlas Episode 9', 9 UNION ALL
  SELECT 'Atlas Episode 10', 10 UNION ALL
  SELECT 'Atlas Episode 11', 11 UNION ALL
  SELECT 'Atlas Episode 12', 12 UNION ALL
  SELECT 'Atlas Episode 13', 13 UNION ALL
  SELECT 'Atlas Episode 14', 14 UNION ALL
  SELECT 'Atlas Episode 15', 15
),

episode_viewers AS (
  SELECT DISTINCT
    se.episode_number,
    se.content_title,
    v.user_id,
    DATE(v.view_start_timestamp) AS view_date
  FROM demo_viewing_events v
  JOIN selected_episodes se
    ON v.content_title = se.content_title
  WHERE DATE(v.view_start_timestamp) BETWEEN start_date AND end_date
    AND v.series_title = 'Atlas Stories'
    AND v.user_id IS NOT NULL
),

viewer_loyalty AS (
  SELECT
    user_id,
    COUNT(DISTINCT episode_number) AS episodes_watched
  FROM episode_viewers
  GROUP BY user_id
),

episode_retention AS (
  SELECT
    curr.episode_number AS from_episode_number,
    curr.content_title AS from_episode_title,

    next_ep.episode_number AS to_episode_number,
    next_ep.content_title AS to_episode_title,

    COUNT(DISTINCT curr.user_id) AS from_episode_unique_viewers,
    COUNT(DISTINCT next_view.user_id) AS retained_to_next_episode,

    SAFE_MULTIPLY(
      SAFE_DIVIDE(
        COUNT(DISTINCT next_view.user_id),
        COUNT(DISTINCT curr.user_id)
      ),
      100
    ) AS retention_to_next_episode_pct

  FROM episode_viewers curr

  LEFT JOIN selected_episodes next_ep
    ON curr.episode_number + 1 = next_ep.episode_number

  LEFT JOIN episode_viewers next_view
    ON next_ep.episode_number = next_view.episode_number
   AND curr.user_id = next_view.user_id

  GROUP BY
    curr.episode_number,
    curr.content_title,
    next_ep.episode_number,
    next_ep.content_title
),

episode_loyalty AS (
  SELECT
    ev.episode_number,
    ev.content_title,

    COUNT(DISTINCT ev.user_id) AS unique_viewers,

    COUNT(DISTINCT CASE
      WHEN vl.episodes_watched >= 3 THEN ev.user_id
    END) AS loyal_viewers_3plus_episodes,

    SAFE_MULTIPLY(
      SAFE_DIVIDE(
        COUNT(DISTINCT CASE WHEN vl.episodes_watched >= 3 THEN ev.user_id END),
        COUNT(DISTINCT ev.user_id)
      ),
      100
    ) AS loyal_viewers_3plus_episodes_pct

  FROM episode_viewers ev
  JOIN viewer_loyalty vl
    ON ev.user_id = vl.user_id
  GROUP BY
    ev.episode_number,
    ev.content_title
)

SELECT
  er.from_episode_number,
  er.from_episode_title,

  er.to_episode_number,
  er.to_episode_title,

  er.from_episode_unique_viewers,
  er.retained_to_next_episode,
  ROUND(er.retention_to_next_episode_pct, 2) AS retention_to_next_episode_pct,

  el.loyal_viewers_3plus_episodes,
  ROUND(el.loyal_viewers_3plus_episodes_pct, 2) AS loyal_viewers_3plus_episodes_pct

FROM episode_retention er
LEFT JOIN episode_loyalty el
  ON er.from_episode_number = el.episode_number

ORDER BY er.from_episode_number;