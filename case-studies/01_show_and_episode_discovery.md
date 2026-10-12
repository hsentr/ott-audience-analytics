# Which episodes bring in new viewers?

## Why I asked this question

A popular episode can attract many viewers. But are they new to the platform, new to the show, or people who already watch it?

## What I measured

I compare the number of people who watched each episode with the number first seen on the platform or watching the show for the first time during the selected dates.

## A simple example

Imagine two episodes with similar audiences. One appears to attract more new viewers, while the other is mostly watched by existing viewers. They may serve different purposes: introducing the show and keeping its audience engaged. This is an example, not a finding from company data.

## How this helps the team

This helps the team choose episodes to investigate for promotion and decide which ones might introduce the show to a wider audience.

## How the numbers are defined

“New to the platform” means the viewer's first recorded viewing day falls within the selected dates. “New to the show” means their first recorded day watching that show falls within those dates. A viewer can belong to both groups, and can watch several episodes on their first show day.

The episode attribution uses a selected record from the first viewing day. The current SQL selects the show and episode independently with `ANY_VALUE`, so this assignment needs validation before it is used to rank acquisition episodes. The counts describe recorded viewing activity, rather than proving what caused someone to join.

## Data coverage

Identifying new viewers depends on having enough historical viewing records. If earlier records are unavailable, “first recorded” may differ from the viewer's actual first watch.

## What I would test next

First, improve the first-watch check. Then compare two promotional approaches fairly and see which leads more new viewers to start watching.

## About the examples

The examples use made-up data. No company results are shared, and the suggested tests have not been carried out as part of this portfolio.

[View the SQL](../sql/01_show_and_episode_discovery.sql) · [View the runnable example](../examples/run_01_show_and_episode_discovery.sql)
