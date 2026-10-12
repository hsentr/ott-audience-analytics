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
-- Business question: which episodes deserve closer engagement review?
-- Measure = maximum session watch-time ratio per viewer and episode.
-- Buckets describe completion bands; exact scene exits require position records.
-- Both publication and viewing dates fall within the selected window.
-- Data-quality rule in this version: NULL ratios reach the final CASE band.
-- Validate missing durations before interpreting the completed-viewer category.
-- Ratios >=1 enter the final band; negative ratios enter the first band.

WITH base AS (
  SELECT
    t1.series_id,
    t1.series_title,
    t1.content_id,
    t1.content_title,
    t1.user_id,

    SAFE_DIVIDE(t1.watched_seconds, t1.video_seconds) AS completion_ratio

  FROM
    demo_viewing_events t1

  WHERE
    t1.series_title LIKE '%Atlas Stories%'
    AND t1.video_seconds > 60

    AND DATE(t1.publish_timestamp) BETWEEN start_date AND end_date

    AND DATE(t1.view_start_timestamp) BETWEEN start_date AND end_date
),

user_max_completion AS (
  SELECT
    series_id,
    series_title,
    content_id,
    content_title,
    user_id,

    MAX(completion_ratio) AS max_completion
  FROM base
  GROUP BY 1,2,3,4,5
),

bucketed AS (
  SELECT
    series_id,
    series_title,
    content_id,
    content_title,
    user_id,

    CASE
      WHEN max_completion < 0.25 THEN '0–25%'
      WHEN max_completion < 0.50 THEN '25–50%'
      WHEN max_completion < 0.75 THEN '50–75%'
      WHEN max_completion < 1.00 THEN '75–99%'
      ELSE '100%'
    END AS drop_off_bucket

  FROM user_max_completion
)

SELECT
  series_id,
  series_title,
  content_id,
  content_title,
  drop_off_bucket,

  COUNT(DISTINCT user_id) AS viewers,

  ROUND(
    COUNT(DISTINCT user_id) * 100.0
    / SUM(COUNT(DISTINCT user_id)) OVER (PARTITION BY content_id),
    2
  ) AS pct_viewers

FROM bucketed

GROUP BY 1,2,3,4,5

ORDER BY
  series_title,
  content_title,
  drop_off_bucket;
