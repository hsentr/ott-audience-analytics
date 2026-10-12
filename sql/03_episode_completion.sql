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

DECLARE start_date DATE DEFAULT '2025-01-01';
DECLARE end_date DATE DEFAULT '2025-02-28';

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
