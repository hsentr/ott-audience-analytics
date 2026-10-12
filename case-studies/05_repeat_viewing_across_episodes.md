# Do the same people watch the next episode?

## Why I asked this question

I want to see whether a show keeps a shared audience across episodes and which viewers watch several episodes.

## What I measured

For each episode, I count how many of its viewers also watched the next numbered episode during the selected dates. I also count viewers who watched at least three different selected episodes.

## A simple example

If 100 people watched Episode 1 and 60 of those people also watched Episode 2, the shared audience is 60%. However, the current code does not check which episode they watched first. These numbers are examples, not company results.

## How this helps the team

If two episodes share few viewers, the team can review the connection between them, their topics, release dates, and how the next episode is recommended.

## How the numbers are defined

The shared-audience percentage counts viewers who watched both an episode and the next numbered episode within the selected dates, divided by the first episode's audience. Both viewing orders are included. The SQL retains the original `retention` column names for compatibility; the business measure presented here is shared audience.

Repeat viewers are people who watched at least three different selected episodes. This is a clear working definition of repeat show engagement. Returning to the wider platform is measured separately. The last selected episode has no next-episode comparison and should be displayed as “Not applicable.”

## Data coverage

Release dates and the reporting window determine which episodes viewers have had the opportunity to watch. Compare results with those opportunities in mind.

## About the examples

The examples use made-up data. No company results are shared, and the suggested tests have not been carried out as part of this portfolio.

[Open the complete BigQuery script](../sql/05_repeat_viewing_across_episodes.sql) · [View the runnable example](../examples/run_05_repeat_viewing_across_episodes.sql)
