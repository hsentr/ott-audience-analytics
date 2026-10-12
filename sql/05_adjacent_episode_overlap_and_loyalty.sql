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

DECLARE start_date DATE DEFAULT '2025-01-01';
DECLARE end_date DATE DEFAULT '2025-02-28';

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