-- GoogleSQL / BigQuery. Public example with entirely synthetic data.
-- Use the complete examples/run_*.sql script to run one demonstration.
-- No employer data or infrastructure is referenced.
-- Fictional dates are editable; original calculations are retained.
-- Business question: do viewers watch more of the same show afterward?
-- Continuation = a different episode watched later within the selected dates.
-- Denominator = distinct viewers of the episode being analyzed.
-- Measures continued show viewing; platform return is a separate question.
-- Reporting end date and episode availability define follow-up opportunities.
-- Arabic alef normalization supports consistent matching of multilingual titles.

DECLARE start_date DATE DEFAULT '2025-01-01';
DECLARE end_date DATE DEFAULT '2025-02-28';

WITH base AS (
  SELECT
    user_id,
    view_start_timestamp,
    REGEXP_REPLACE(TRIM(content_title), r'[إأآٱ]', 'ا') AS content_title_n,
    REGEXP_REPLACE(TRIM(series_title),  r'[إأآٱ]', 'ا') AS series_title_n
  FROM
    demo_viewing_events
  WHERE
    user_id IS NOT NULL
    AND view_start_timestamp IS NOT NULL
    AND DATE(view_start_timestamp) BETWEEN start_date AND end_date
),

series_label AS (
  SELECT
    REGEXP_REPLACE('Atlas Stories', r'[إأآٱ]', 'ا') AS series_title_n
),

show_base AS (
  SELECT b.*
  FROM base b
  JOIN series_label sl
    ON b.series_title_n = sl.series_title_n
),

episode_first_view AS (
  SELECT
    content_title_n AS content_title,
    user_id,
    MIN(view_start_timestamp) AS first_view_at
  FROM show_base
  GROUP BY
    content_title,
    user_id
),

continued AS (
  SELECT
    a.content_title,
    a.user_id
  FROM episode_first_view a
  JOIN show_base b
    ON a.user_id = b.user_id
   AND b.content_title_n != a.content_title
   AND b.view_start_timestamp > a.first_view_at
)

SELECT
  ef.content_title,

  COUNT(DISTINCT ef.user_id) AS unique_viewers,

  'Users continued watching other episodes' AS continued_label,

  COUNT(DISTINCT c.user_id) AS continued_unique_viewers,

  SAFE_DIVIDE(
    COUNT(DISTINCT c.user_id),
    COUNT(DISTINCT ef.user_id)
  ) AS continued_rate,

  SAFE_MULTIPLY(
    SAFE_DIVIDE(
      COUNT(DISTINCT c.user_id),
      COUNT(DISTINCT ef.user_id)
    ),
    100
  ) AS continued_rate_pct

FROM episode_first_view ef

LEFT JOIN continued c
  ON ef.content_title = c.content_title
 AND ef.user_id = c.user_id

GROUP BY
  ef.content_title

ORDER BY
  unique_viewers DESC;
