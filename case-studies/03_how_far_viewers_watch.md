# How far do people watch an episode?

## Why I asked this question

An episode can get many viewers but lose their attention early. I want to identify episodes that need a closer review.

## What I measured

I divide the time watched by the full episode length. For each viewer and episode, I keep their highest result and group viewers by how far they watched: under 25%, 25–50%, 50–75%, 75–100%, or at least 100%.

## A simple example

For a 20-minute episode, watching under 25% means watching less than five minutes in the measured session. If many viewers fall into this group, the opening is worth investigating. This does not prove that the opening is the problem.

## How this helps the team

The team can prioritize episodes for review, then examine the opening, pacing, audience expectations, and possible playback problems.

## How the numbers are defined

Each viewer is assigned to a viewing band using their highest recorded session watch time divided by the full episode length. Percentages show each band's share of the episode's distinct viewers.

These bands provide an overview of how far people watched. Exact scene-level exits require playback-position records. A large early band is a reason to investigate the opening, audience expectations, and playback experience together.

## Data quality

Missing watch durations must be checked before interpreting results: the current SQL assigns a missing completion ratio to the final band. The measure uses the longest recorded session, rather than adding separate sessions together.

## About the examples

The examples use made-up data. No company results are shared, and the suggested tests have not been carried out as part of this portfolio.

[Open the complete BigQuery script](../sql/03_how_far_viewers_watch.sql) · [View the runnable example](../examples/run_03_how_far_viewers_watch.sql)
