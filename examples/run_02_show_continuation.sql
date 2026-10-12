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
-- Business question: do viewers watch more of the same show afterward?
-- Continuation = a different episode watched later within the selected dates.
-- Denominator = distinct viewers of the episode being analyzed.
-- Measures continued show viewing; platform return is a separate question.
-- Reporting end date and episode availability define follow-up opportunities.
-- Arabic alef normalization supports consistent matching of multilingual titles.

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
