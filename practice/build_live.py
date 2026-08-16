#!/usr/bin/env python3
"""Generate browser-runnable (WebR) versions of the practice notebooks.

Reads each `<name>.qmd` exercise notebook plus its `<name>_answers.qmd` companion and
writes `<name>_live.qmd`, in which every R chunk becomes an editable `{webr}` cell that
runs client-side. Chunks containing a `...` placeholder get a collapsed callout holding
the corresponding chunk from the answer key.

The exercise and answer notebooks share byte-identical prose, so chunks pair up by
position. That is asserted rather than assumed.

Run from the `practice` directory:  python3 build_live.py
"""

import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).parent

TRACKED = set(subprocess.run(
    ["git", "ls-files", "data"], cwd=HERE, capture_output=True, text=True, check=True
).stdout.split())

# Notebooks to convert, with the packages each needs loaded into WebR up front.
# Data dependencies are detected from the source rather than listed here.
MODULES = {
    "p1_programming_basics": ["ggplot2", "maps"],
    "p2_R_fundamentals": ["ggplot2"],
    "p3_basic_tabular_manipulation": ["ggplot2", "dplyr"],
    "p4_adv_tabular_data": ["tidyverse"],
    "p5_functional_programming": ["tidyverse"],
    "extra_demo_datatypes": ["tidyverse"],
}

CHUNK = re.compile(r"^```\{r[^}]*\}\n(.*?)^```\n", re.DOTALL | re.MULTILINE)

BANNER = """::: {{.callout-note appearance="simple"}}
This page runs R inside your browser: nothing to install and nothing to set up. R and the
packages start loading the moment the page opens, which takes up to a minute the first
time and is quick on later visits. Run the cells in order from the top, since they share
one session, and edit anything you like to try something out.{answer_note} To work through
it on your own machine instead, download {downloads} from the
[course page](../index.html#optional-practice-exercises).
:::

"""

ANSWER_NOTE = " Each answer sits in a collapsed box under the cell it belongs to."


def split_chunks(text):
    """Return (prose_pieces, chunk_bodies) such that prose interleaves the chunks."""
    prose, bodies, pos = [], [], 0
    for m in CHUNK.finditer(text):
        prose.append(text[pos:m.start()])
        bodies.append(m.group(1))
        pos = m.end()
    prose.append(text[pos:])
    return prose, bodies


def solution_block(body):
    return (
        '::: {.callout-tip collapse="true"}\n'
        "## Show the answer\n"
        "```r\n"
        f"{body.rstrip()}\n"
        "```\n"
        ":::\n"
    )


def build(name, packages):
    ex_path, ans_path = HERE / f"{name}.qmd", HERE / f"{name}_answers.qmd"
    ex_text = ex_path.read_text()
    # extra_demo_datatypes is a worked example with nothing to fill in, so it has no key.
    has_answers = ans_path.exists()
    ans_text = ans_path.read_text() if has_answers else ex_text

    ex_prose, ex_bodies = split_chunks(ex_text)
    _, ans_bodies = split_chunks(ans_text)
    if len(ex_bodies) != len(ans_bodies):
        sys.exit(f"{name}: {len(ex_bodies)} chunks but {len(ans_bodies)} in the answer key")

    title = re.search(r'^title: "(.*)"$', ex_text, re.MULTILINE).group(1)

    # Data files the notebook reads, in first-use order. Restricted to files git tracks:
    # extra_demo writes data/exam_summaries.csv, which exists locally but is ignored and
    # so will not be on the server for the browser to fetch.
    data = [d for d in dict.fromkeys(re.findall(r'data/[A-Za-z0-9_]+\.csv', ex_text))
            if d in TRACKED]

    out = [
        "---\n",
        f'title: "{title}"\n',
        "format: live-html\n",
        "engine: knitr\n",
        "webr:\n",
        "  packages:\n",
    ]
    out += [f"    - {p}\n" for p in packages]
    if data:
        out.append("  resources:\n")
        out += [f"    - {d}\n" for d in data]
    out.append("resources:\n")
    out += [f"  - {d}\n" for d in data]
    out.append("---\n\n")
    out.append("{{< include _extensions/r-wasm/live/_knitr.qmd >}}\n\n")

    # Drop the original YAML header from the first prose piece and lead with the banner.
    first = re.sub(r"\A---\n.*?\n---\n\n", "", ex_prose[0], flags=re.DOTALL)
    if has_answers:
        downloads = f"[the notebook]({name}.qmd) and [the answer key]({name}_answers.qmd)"
    else:
        downloads = f"[the notebook]({name}.qmd)"
    out.append(BANNER.format(
        answer_note=ANSWER_NOTE if has_answers else "",
        downloads=downloads,
    ))
    out.append(first)

    n_solutions = 0
    for i, (ex_body, ans_body) in enumerate(zip(ex_bodies, ans_bodies)):
        # The setup chunk only configures knitr hooks, which do not apply to webr cells.
        if i == 0 and "knit_hooks" in ex_body:
            out.append(ex_prose[i + 1].lstrip("\n"))
            continue
        out.append("```{webr}\n" + ex_body + "```\n")
        if "..." in ex_body and ex_body != ans_body:
            out.append("\n" + solution_block(ans_body))
            n_solutions += 1
        out.append(ex_prose[i + 1])

    (HERE / f"{name}_live.qmd").write_text("".join(out))
    print(f"{name:<34} {len(ex_bodies):>2} cells, {n_solutions:>2} solutions, data: {', '.join(d.split('/')[-1] for d in data) or 'none'}")


if __name__ == "__main__":
    for name, packages in MODULES.items():
        build(name, packages)
