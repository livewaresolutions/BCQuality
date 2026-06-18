---
bc-version: [26..28]
domain: testing
keywords: [al-runner, test-isolation, fixture, initialize, deleteall, in-memory-store]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Isolate AL Runner tests with an Initialize fixture

## Description

AL Runner keeps its mocked records in an in-memory store, and in current versions that store is **not reliably reset between test methods** — rows inserted by one test remain visible to the next, even across different test codeunits. A suite that arranges data without first clearing it will produce false passes and false failures that depend purely on the order tests happen to run in. Because there is no BC service tier and no demo data, every test must also create the records it needs from scratch. Both needs are solved the same way they are in container-based BC testing: a shared fixture library codeunit.

## Best Practice

Build a single fixture (library) codeunit for the suite with two kinds of method: an `Initialize` procedure that `DeleteAll(false)` on every table the suite touches, and `Create*` seeders that insert the records tests need. Call `Initialize` as the **first line of every `[Test]` method**, then arrange with the seeders. Seed with `Insert(false)` so the (non-executing) base-application insert logic and your own event subscribers do not interfere with arrange; the product code under test still exercises its real `Insert(true)` paths. Seeding the current user's `User Setup` row or a `Resource` linked by `UserId()` works because the runner returns a stable user id.

## Anti Pattern

Relying on the runner to give each test a clean store, or sharing arranged data implicitly between tests. The symptom is a suite that passes when run as a whole but fails when a single test runs alone, or vice versa — and assertions that succeed only because of rows a neighbouring test left behind. In review, a `[Test]` whose first action is to arrange data without a preceding `Initialize`/reset call is the signal.
