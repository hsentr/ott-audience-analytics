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
WITH first_platform_view AS (
  SELECT
    user_id,
    MIN(DATE(view_start_timestamp)) AS first_view_date
  FROM
    demo_viewing_events
  GROUP BY
    user_id
),

first_show_view AS (
  SELECT
    user_id,
    series_title,
    MIN(DATE(view_start_timestamp)) AS first_show_date
  FROM
    demo_viewing_events
  WHERE
    series_title IS NOT NULL
  GROUP BY
    user_id,
    series_title
),

first_content_per_user AS (
  SELECT
    f.user_id,
    f.first_view_date,
    ANY_VALUE(v.series_title) AS first_show,
    ANY_VALUE(v.content_title) AS first_content_title
  FROM
    first_platform_view f
  JOIN
    demo_viewing_events v
    ON f.user_id = v.user_id
   AND DATE(v.view_start_timestamp) = f.first_view_date
  GROUP BY
    f.user_id,
    f.first_view_date
),

content_viewers AS (
  SELECT
    content_title,
    user_id
  FROM
    demo_viewing_events
  WHERE
    DATE(view_start_timestamp) BETWEEN start_date AND end_date
    AND series_title = 'Atlas Stories'
),

new_to_platform AS (
  SELECT
    first_content_title AS content_title,
    user_id
  FROM
    first_content_per_user
  WHERE
    first_show = 'Atlas Stories'
    AND first_view_date BETWEEN start_date AND end_date
),

new_to_show AS (
  SELECT
    v.content_title,
    v.user_id
  FROM
    demo_viewing_events v
  JOIN
    first_show_view f
    ON v.user_id = f.user_id
   AND v.series_title = f.series_title
   AND DATE(v.view_start_timestamp) = f.first_show_date
  WHERE
    v.series_title = 'Atlas Stories'
    AND f.first_show_date BETWEEN start_date AND end_date
)

SELECT
  cv.content_title,

  COUNT(DISTINCT cv.user_id) AS total_unique_viewers,

  COUNT(DISTINCT ntp.user_id) AS new_to_platform,

  COUNT(DISTINCT nts.user_id) AS new_to_show

FROM
  content_viewers cv

LEFT JOIN
  new_to_platform ntp
  ON cv.user_id = ntp.user_id
 AND cv.content_title = ntp.content_title

LEFT JOIN
  new_to_show nts
  ON cv.user_id = nts.user_id
 AND cv.content_title = nts.content_title

GROUP BY
  cv.content_title

ORDER BY
  total_unique_viewers DESC;
