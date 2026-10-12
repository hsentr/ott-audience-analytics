# Synthetic schema

Grain: one viewing event per row; the fixture contains one unique view_id per event.

| Field | Type | Meaning |
|---|---|---|
| user_id | STRING | Fictional stable viewer identifier |
| registered_user_id | STRING | Fictional registration identifier, nullable |
| is_guest | BOOL | Guest flag at the event |
| view_id | STRING | Event identifier and first-touch tie-breaker |
| view_start_timestamp | TIMESTAMP | Viewing start in UTC |
| event_date | DATE | Reporting date; UTC date of event in fixture |
| publish_timestamp | TIMESTAMP | Episode publication time |
| series_id / series_title | STRING | Fictional show identity |
| content_id / content_title | STRING | Fictional episode identity |
| watched_seconds / video_seconds | FLOAT64 | Event watch duration and full episode duration |
| video_type | STRING | VOD or LIVE |
| content_type | STRING | CONTENT for eligible full content |

