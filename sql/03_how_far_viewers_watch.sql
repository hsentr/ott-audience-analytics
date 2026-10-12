-- COMPLETE BIGQUERY DEMONSTRATION: copy this ENTIRE file and click Run.
-- Do not select only the WITH/SELECT section: the sample table is created below.
-- No dataset name or employer access is required. All records are fictional.
-- Original analytical calculations retained. See the linked business story.
DECLARE start_date DATE DEFAULT '2025-01-01';
DECLARE end_date DATE DEFAULT '2025-02-28';


-- Step 1: create the synthetic viewing table.
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

-- Step 2: answer the business question.
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
