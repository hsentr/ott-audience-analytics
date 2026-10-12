-- COMPLETE BIGQUERY DEMONSTRATION: copy this ENTIRE file and click Run.
-- Do not select only the WITH/SELECT section: the sample table is created below.
-- No dataset name or employer access is required. All records are fictional.
-- Original analytical calculations retained. See the linked business story.

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
WITH periods AS (
  SELECT
    'Period A' AS wall,
    'Synthetic baseline' AS period_label,
    DATE '2025-01-01' AS start_date,
    DATE '2025-01-31' AS end_date

  UNION ALL

  SELECT
    'Period B' AS wall,
    'Synthetic follow-up' AS period_label,
    DATE '2025-02-01' AS start_date,
    DATE '2025-02-28' AS end_date
),

base AS (
  SELECT
    p.wall,
    p.period_label,

    v.user_id,
    v.registered_user_id,
    v.is_guest,
    v.view_id,
    v.view_start_timestamp,

    COALESCE(
      NULLIF(NULLIF(TRIM(v.series_title), ''), '-'),
      NULLIF(TRIM(v.content_title), ''),
      '(Unmapped)'
    ) AS program_name

  FROM
    demo_viewing_events AS v

  JOIN periods AS p
    ON v.event_date BETWEEN p.start_date AND p.end_date

  WHERE UPPER(COALESCE(v.video_type, '')) = 'VOD'
    AND v.user_id IS NOT NULL
    AND v.view_id IS NOT NULL

    AND content_type = 'CONTENT'

),

total_show_viewers AS (
  SELECT
    wall,
    period_label,
    program_name AS first_content_watched,

    COUNT(DISTINCT user_id) AS total_show_unique_viewers

  FROM base

  GROUP BY
    wall,
    period_label,
    program_name
),

ranked_first_view AS (
  SELECT
    *,

    ROW_NUMBER() OVER (
      PARTITION BY wall, user_id
      ORDER BY
        view_start_timestamp,
        view_id
    ) AS first_view_rank

  FROM base
),

first_touch AS (
  SELECT
    wall,
    period_label,
    user_id,
    registered_user_id,
    is_guest,
    program_name AS first_content_watched,

    CASE
      WHEN is_guest IS FALSE
        OR registered_user_id IS NOT NULL
      THEN 'Registered'
      ELSE 'Guest'
    END AS viewer_status

  FROM ranked_first_view

  WHERE first_view_rank = 1
),

first_touch_metrics AS (
  SELECT
    wall,
    period_label,
    first_content_watched,

    COUNT(
      DISTINCT user_id
    ) AS first_content_watched_unique_viewers,

    COUNT(
      DISTINCT IF(
        viewer_status = 'Registered',
        user_id,
        NULL
      )
    ) AS registered_unique_viewers,

    COUNT(
      DISTINCT IF(
        viewer_status = 'Guest',
        user_id,
        NULL
      )
    ) AS guest_unique_viewers

  FROM first_touch

  GROUP BY
    wall,
    period_label,
    first_content_watched
),

metrics_with_rates AS (
  SELECT
    f.wall,
    f.period_label,
    f.first_content_watched,

    COALESCE(
      t.total_show_unique_viewers,
      0
    ) AS total_show_unique_viewers,

    f.first_content_watched_unique_viewers,
    f.registered_unique_viewers,

    ROUND(
      100 * SAFE_DIVIDE(
        f.registered_unique_viewers,
        f.first_content_watched_unique_viewers
      ),
      2
    ) AS registered_pct_of_first_content_watched_unique_viewers,

    f.guest_unique_viewers,

    ROUND(
      100 * SAFE_DIVIDE(
        f.guest_unique_viewers,
        f.first_content_watched_unique_viewers
      ),
      2
    ) AS guest_pct_of_first_content_watched_unique_viewers

  FROM first_touch_metrics AS f

  LEFT JOIN total_show_viewers AS t
    ON f.wall = t.wall
    AND f.period_label = t.period_label
    AND f.first_content_watched = t.first_content_watched
),

ranked_programs AS (
  SELECT
    *,

    ROW_NUMBER() OVER (
      PARTITION BY wall
      ORDER BY
        first_content_watched_unique_viewers DESC,
        registered_unique_viewers DESC,
        first_content_watched
    ) AS program_rank

  FROM metrics_with_rates
)

SELECT
  wall,
  period_label,
  program_rank AS rank,
  first_content_watched,
  total_show_unique_viewers,
  first_content_watched_unique_viewers,
  registered_unique_viewers,
  registered_pct_of_first_content_watched_unique_viewers,
  guest_unique_viewers,
  guest_pct_of_first_content_watched_unique_viewers

FROM ranked_programs

WHERE program_rank <= 20

ORDER BY
  CASE wall
    WHEN 'Period A' THEN 1
    WHEN 'Period B' THEN 2
  END,
  program_rank;
