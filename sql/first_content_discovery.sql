-- GoogleSQL / BigQuery. Public example with entirely synthetic data.
-- Use the complete examples/run_*.sql script to run one demonstration.
-- No employer data or infrastructure is referenced.
-- Fictional dates are editable; original calculations are retained.
-- Business question: which programs start a viewer's reporting-period journey?
-- First = earliest eligible VOD / CONTENT record within each period.
-- Registration status is taken at first touch using the original OR rule.
-- Order = viewing timestamp, then view_id; NULL timestamps use default ordering.
-- Period-first viewing and lifetime-first acquisition are separate measures.
-- Program name falls back from series title to episode title.

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
