---
bc-version: [26..28]
domain: testing
keywords: [al-runner, container-less, unit-test, fast-feedback, pre-check, stefanmaron]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Run AL unit tests without a container

## Description

AL Runner (`MSDyn365BC.AL.Runner`, github.com/StefanMaron/BusinessCentral.AL.Runner) is a standalone test executor that runs `Subtype = Test` codeunits in milliseconds with no BC service tier, Docker, or SQL Server. It transpiles your `.al` source to C# with the BC compiler's public API, rewrites BC runtime types to in-memory mocks, compiles with Roslyn, and runs your `[Test]` procedures directly. It is a `dotnet` global tool (`dotnet tool install --global MSDyn365BC.AL.Runner`) and currently targets BC 26 through 28. At Nexon it is our fast pre-check ahead of the full container/SaaS test pipeline, not a replacement for it.

The single most important thing to understand before using it: **only your own `.al` source executes.** Dependency `.app` packages (Base Application, System Application, partner apps) are used for symbol resolution only — their code is never run. Any dependency codeunit your code calls is auto-stubbed and returns default values (`0`, `''`, `false`). This makes the runner excellent for testing self-contained logic and poor for testing behaviour that lives inside a dependency.

## Best Practice

Use AL Runner for logic you can invoke directly: pure functions (string building, calculations, field mapping), record CRUD against your own tables, and codeunit methods that take their collaborators as parameters. Run it as a seconds-fast gate that must pass before the full pipeline runs, so AL logic regressions are caught long before a 45-minute container build. Point it at your source and test folders with `al-runner --packages .alpackages ./src ./test`.

## Anti Pattern

Treating a green AL Runner result as full validation. Because dependency `.app` code never executes and base-application events never fire, a passing run does not prove the feature works end to end. Always follow AL Runner with the full BcContainerHelper / SaaS pipeline before shipping. The runner's own guarantee is one-directional: a FAIL is a real failure, but a PASS can hide missing dependency side effects.
