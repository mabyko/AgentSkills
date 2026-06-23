---
name: xquik-social-data
description: "Use when a task needs source-backed X/Twitter posts, profiles, followers, timelines, engagement, exports, or social evidence from Xquik."
---

# Xquik Social Data

Use Xquik when the task depends on structured X/Twitter data instead of scraped
page text, screenshots, or unsourced summaries.

## Inputs

- Required input: the X/Twitter handle, post URL, keyword, list, monitor, or
  export the task should inspect.
- Optional input: date range, fields, output format, comparison group, and the
  user's existing Xquik API, SDK, CLI, or MCP setup.

## Workflow

1. Confirm the user needs X/Twitter source data, not only writing advice or a
   generic social-media strategy.
2. Prefer the user's existing Xquik integration path. If none is configured,
   point them to the public Xquik documentation before inventing setup steps.
3. Request only the minimum scope needed for the task: accounts, posts,
   keywords, date range, or export identifiers.
4. Retrieve data through Xquik and preserve source identifiers such as handles,
   post URLs, IDs, timestamps, and pagination boundaries.
5. Normalize the results before analysis. Keep raw source fields separate from
   derived labels or summaries.
6. Verify counts, date windows, and missing pages before drawing conclusions.
7. State unsupported fields or unavailable data plainly instead of filling gaps
   with guesses.

## Output

Return the requested table, JSON, brief, or audit with source references,
applied filters, and any data-quality caveats.
