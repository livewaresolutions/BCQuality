---
bc-version: [26..28]
domain: testing
keywords: [al-runner, dependencies, auto-stub, stubs, compile-dep, dep-dlls]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose the right AL Runner dependency strategy

## Description

Most AL projects call into the Base Application, System Application, or partner apps. AL Runner never executes that dependency code — it only resolves symbols from the `.app` packages you pass via `--packages`. When your code calls a dependency codeunit, the runner gives you one of three escalating ways to satisfy it, and picking the right one decides whether a test is meaningful or silently hollow.

The three options, simplest first: **auto-stubs** (default, zero config) generate empty methods that return defaults — fine when your test mocks its own collaborators, wrong when the test relies on real dependency behaviour; **hand-written stubs** (`--stubs ./stubs`, optionally scaffolded with `--generate-stubs`) let you return controlled values for specific dependency methods; **compiled dependency DLLs** (`--compile-dep MyDep.app ./deps` then `--dep-dlls ./deps`) compile a dependency's AL source to a rewritten DLL so its real logic executes in-memory.

## Best Practice

Default to auto-stubs and design tests that do not depend on dependency behaviour. When a test genuinely needs a specific return value from a dependency method, write a small hand-written stub for just that method — it is explicit and keeps the test readable. Reserve `--compile-dep` for cases where you own the dependency's AL source and need its real behaviour faithfully; it is the most powerful option but also the heaviest to maintain.

## Anti Pattern

Asserting on a value that flows through an auto-stubbed dependency call. Because auto-stubs return `0` / `''` / `false`, the assertion either passes for the wrong reason or fails in a way that looks like a product bug. The runner reports how many objects it auto-stubbed at the top of its output — treat a test that reads a result derived from an auto-stubbed call as not yet trustworthy until you supply a real stub or compiled dependency.
