-- GoogleSQL / BigQuery. Public example with entirely synthetic data.
-- Use the complete examples/run_*.sql script to run one demonstration.
-- No employer data or infrastructure is referenced.
-- Fictional dates are editable; original calculations are retained.
-- Business question: which episodes introduce viewers to the show/platform?
-- New = first recorded viewing day within the report window.
-- Show newcomers include platform newcomers; audience groups overlap.
-- Several episodes may be watched on a viewer's first show day.
-- Attribution definition: ANY_VALUE selects show and episode independently
-- from first-day records. Validate assignment before ranking acquisition episodes.
-- History coverage determines how accurately first-recorded activity is identified.

DECLARE start_date DATE DEFAULT '2025-01-01';
DECLARE end_date DATE DEFAULT '2025-02-28';

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
