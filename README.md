# From First Watch to the Next Episode

How I use BigQuery SQL to understand where viewers start, which episodes attract new audiences, and what keeps people watching.

A show's audience size tells only part of its story. I explore four connected questions to help content, marketing, and product teams decide what to promote, what to review, and where to improve.

**First program watched → New-viewer discovery → How far people watch → Watching another episode**

## 1. Where do viewers start?

I identify the first eligible program each person watches during a reporting period and whether they are registered or watching as a guest at that time.

This helps the team understand where viewing journeys begin and which programs to consider for the home page or welcome experience.

First viewing during a period can include existing users. The next question focuses on viewers newly observed on the platform or discovering the show.

[Read the story](case-studies/01_first_program_watched.md) · [View the SQL](sql/01_first_program_watched.sql)

## 2. Which episodes attract new viewers?

I look at a specific show and compare each episode's audience with people newly observed on the platform and people watching the show for the first time.

This helps distinguish episodes that reach new audiences from those watched mainly by existing viewers. The team can use this to identify candidates for promotion.

These counts describe recorded viewing. They do not by themselves prove that an episode caused someone to join.

[Read the story](case-studies/02_episodes_and_new_viewers.md) · [View the SQL](sql/02_episodes_and_new_viewers.sql)

## 3. How far do viewers watch an episode?

Attracting viewers is only the beginning. I group viewers by how much of an episode they watched, using their highest recorded session watch time compared with the full episode length.

This helps identify episodes that deserve a closer review. If many viewers watch only a small part, the team can investigate the opening, pacing, audience expectations, and playback experience.

These groups show broad viewing patterns. Exact moments where people stop require more detailed playback records.

[Read the story](case-studies/03_how_far_viewers_watch.md) · [View the SQL](sql/03_how_far_viewers_watch.sql)

## 4. Do viewers watch more of the show?

Finally, I check whether viewers watch a different episode of the same show afterward, within the reporting period.

This helps the team review episode endings, recommendations, and links to other episodes. It asks whether people keep exploring the show after their first watch of an episode.

[Read the story](case-studies/04_watching_more_of_the_show.md) · [View the SQL](sql/04_watching_more_of_the_show.sql)

### A closer look at repeat viewing

I also examine how many viewers are shared between adjacent numbered episodes and how many watched at least three selected episodes. This adds another view of repeat engagement with the show.

The adjacent-episode measure counts people who watched both episodes in either order. Watching more of one show and returning to the wider platform are separate questions.

[Read the story](case-studies/05_repeat_viewing_across_episodes.md) · [View the SQL](sql/05_repeat_viewing_across_episodes.sql)

## Using the analysis

Each story connects a business question to a measurement and explains how the team can use it. Together, the analyses help prioritize content promotion, editorial review, and improvements to the viewing experience.

These are different views of audience behavior, rather than one group tracked through a single funnel.

## Skills demonstrated

- Turning business questions into clear measurements
- Identifying first viewing and new-viewer groups
- Measuring episode engagement and continued viewing
- Combining records, ordering events, and calculating counts and percentages in SQL
- Explaining the analysis in business terms and connecting it to decisions

## About the data and results

These are public examples based on analytical approaches from my work. All show names, dates, user IDs, table names, and sample records are made up. No employer data or actual business results are shared.

Each story includes a simple explanation and links to its SQL. Example numbers are for explanation only. No completed experiments or company findings are claimed.

Each story explains how its numbers are defined and how the team can use them. The measures cover first recorded viewing, later viewing of the same show, completion bands, first viewing within a period, and shared viewers across episodes. Historical coverage, episode availability, and the reporting window provide context for interpretation. Technical measurement details are documented beside the SQL.

## Run an example in BigQuery

1. Open any `.sql` file in `sql/`.
2. Copy the ENTIRE file, including the sample-data setup at the top.
3. Paste it into a new BigQuery query tab using GoogleSQL.
4. Clear any highlighted text, then click Run to execute the full script.
5. Return to the query tab and open the result of the final SELECT statement, rather than the temporary table Preview. In script results, this may appear as the last child job.

Every file creates its own temporary viewing table before running the analysis. No separate setup, dataset name, or employer table is needed. Date variables appear before table creation, as required by BigQuery. Run one file at a time. The `examples/` folder contains identical convenience copies.

If you see “Table demo_viewing_events must be qualified with a dataset,” check that you copied and ran the entire file. Running only the bottom analysis skips the temporary-table setup.
