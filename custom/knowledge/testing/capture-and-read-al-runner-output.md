---
bc-version: [26..28]
domain: testing
keywords: [al-runner, output-json, stdout, console-handle, banner, exit-code, capture]
technologies: [al, powershell]
countries: [w1]
application-area: [all]
---

# Capture and read AL Runner output correctly

## Description

AL Runner reports results to the console and, with `--output-json`, emits a machine-readable summary (`passed`, `failed`, `errors`, `total`, `exitCode`, and a `tests` array). Two behaviours trip up first-time users. First, the tool writes to the console handle rather than a clean stdout stream, so a result that looks empty in an interactive terminal ("Command produced no output") has in fact run — you must redirect it to a file to see it. Second, the runner prints a human banner (for example `Auto-stubbed N object(s)…`) *interleaved with* the JSON, so the captured text is not a single valid JSON document. Piping it straight into a JSON parser fails with a parse error at position 0 even though the run succeeded.

## Best Practice

Redirect both streams to a file and read the file, rather than trusting the live terminal: append `--output-json` and capture with `2>&1 | Set-Content results.json -Encoding utf8` (or `*> results.json`). To read the outcome, extract the summary lines (`passed`, `failed`, `errors`, `exitCode`) and any `"status": "fail"` entries with a text search such as `Select-String`, instead of `ConvertFrom-Json` on the whole file. Drive automation off the process exit code, which is reliable: `0` all passed, `1` real failures or usage error, `2` runner-limitation-only, `3` compilation error.

## Anti Pattern

Reading the interactive terminal output to decide pass/fail, or `ConvertFrom-Json`-ing the raw captured output. The first reports a false "no output" because the result went to the console handle; the second throws a parse error because the auto-stub banner is mixed into the JSON. Both look like the runner is broken when the tests actually ran — the fix is to capture to a file and parse the summary lines or the exit code.
