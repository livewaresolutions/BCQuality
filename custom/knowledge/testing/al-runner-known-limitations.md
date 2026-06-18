---
bc-version: [26..28]
domain: testing
keywords: [al-runner, limitations, exit-code, error-vs-fail, rewriter, scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Know what AL Runner cannot run, and read its outcomes correctly

## Description

AL Runner emulates the AL runtime in-memory, so a defined set of features cannot work and certain results mean "unsupported," not "broken." Knowing these boundaries up front stops you from writing tests that can never pass and from misreading a runner limitation as a product bug.

Features that cannot run: code inside `.app` packages (dependencies are symbol-only / auto-stubbed); transaction semantics (`Commit`/`Rollback` are no-ops); base-application event firing (an `OnAfterInsert` raised by base-app insert code never fires, because that insert code lives in an `.app`); UI rendering and page layout; multi-dataitem queries (JOINs); real HTTP (`HttpClient.Send` throws — inject via an AL interface instead); and XmlPort `Import`/`Export`.

## Applies to

Outcome semantics matter as much as the limitations. Each test ends as exactly one of: **PASS** (your logic is correct), **FAIL** (a real assertion failure or thrown exception — trust it), or **ERROR** (the code hit an unsupported feature — a configuration issue, not a test failure). Exit codes follow the same idea: `0` all passed, `1` real assertion failures or a usage error, `2` runner-limitation-only outcomes (promote to `1` with `--strict`), `3` AL compilation error.

## Anti Pattern

Passing the whole app to the runner when one object uses an unsupported construct. The runner compiles every directory you give it as a single project, so a single object the rewriter cannot handle (commonly report objects, which surface as a Roslyn `CS0030` "cannot convert NavValue to MockRecordHandle") fails the entire compile (exit `3`) and no tests run. Scope the invocation to the folders under test and exclude objects that are not unit-test targets, rather than pointing the runner at the full source tree.
