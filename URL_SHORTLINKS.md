# Data URLs used in the slides

The slides read their data straight from `raw.githubusercontent.com` on this branch, so they
work as soon as the branch is pushed and nothing has to be set up by hand. The URLs are long,
though, which is ugly on a slide and awkward for anyone typing rather than pasting.

If you want short links back, create one per row below, fill in the middle column, then run a
find-and-replace across `lectures/*.qmd` and re-render. Every URL shares the same prefix:

```
https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/mph-nhanes/
```

## Data files

| Path after the prefix | Short link | Used in |
|---|---|---|
| `data/nhanes/nhanes_subset.csv` | | lectures 1, 2 |
| `data/poly.csv` | | lecture 1 |
| `data/nhanes/nhanes.csv` | | lectures 3, 4 |
| `data/nhanes/nhanes_cycle_counts.csv` | | lecture 4 |
| `data/pollution.csv` | | lecture 4 |
| `data/nhanes/nhanes_exams.csv` | | lecture 4 |
| `data/nhanes/nhanes_participants.csv` | | lecture 4 |
| `data/nhanes/nhanes_sessions.csv` | | lecture 4 |
| `data/nhanes/nhanes_monthly_components.csv` | | lecture 4 |
| `data/nhanes/nhanes_monthly_exams.csv` | | lecture 4 |

Lecture 5 builds its URLs by pasting the prefix onto file names, so it needs the directory
rather than individual files:

| Path after the prefix | Short link | Used in |
|---|---|---|
| `data/nhanes/` | | lecture 5 |
| `data/results` | | lecture 5 |

Lecture 5 reads `nhanes_monthly_exams.csv`, `nhanes_monthly_components.csv`, and
`nhanes_exam_dates.csv` out of that directory.

## Images

These are referenced as images rather than read as data, so shortening them buys nothing. They
are listed for completeness, since they also carry the branch name and would need updating if
the branch is ever renamed.

- `figures/relational_data.png` (lecture 4, via the `raw.githubusercontent.com` prefix)
- `figures/call.png`, `x_changes.png`, `x_gets_1.png`, `x_is_1.jpg`, `x_squared.png`,
  `y_gets_x.png` (lectures 2 and 5, via `https://github.com/alejandroschuler/r4ds-courses/blob/mph-nhanes/...?raw=true`)

## If you rename the branch

The branch name `mph-nhanes` is baked into every URL above. To move to a different branch name,
replace it everywhere:

```bash
grep -rl mph-nhanes lectures/ | xargs sed -i '' 's/mph-nhanes/NEW-BRANCH-NAME/g'
```

Then re-render the decks.
