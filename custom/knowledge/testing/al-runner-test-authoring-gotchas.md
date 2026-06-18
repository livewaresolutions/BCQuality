---
bc-version: [26..28]
domain: testing
keywords: [al-runner, setup-table, test-isolation, code-overflow, library-assert, vscode-lint]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid the common AL Runner test-authoring traps

## Description

A handful of recurring mistakes make AL Runner tests fail for reasons unrelated to the code under test. Recognising them turns a confusing red run into a quick fix. They are the practical lessons Nexon hit when first adopting the runner, and they show up as misleading errors rather than real assertion failures.

## Best Practice

Seed setup and singleton tables through the table's own accessor, then `Modify`, rather than a blind `Insert`. Many setup tables auto-create their single row on first read (an overridden `Get`/`GetRecordOnce`), so if the code under test reads the setup before your test inserts it, a second `Insert` collides on the primary key. Calling the table's `Get` first upserts safely and uses the same path production code uses.

Pass test inputs that respect the parameter's length. The runner enforces `Code`/`Text` lengths at the call boundary, so handing a 23-character literal to a `Code[20]` parameter raises a string-length exception before your procedure runs — keep literal arguments within the declared length and assert truncation on the *result*, not the input.

Ignore the AL extension's "missing" squiggles on test code. The test toolkit codeunits (`Library Assert`, `Library - Variable Storage`, `Any`, `Library - Random`, `Library - Utility`, `Library - Test Initialize`) are auto-loaded by the runner, and it compiles every source folder you pass as one project. A test project whose `.alpackages` lacks those symbols will show them as missing in VS Code, but the runner resolves them fine — verify against the runner, not the editor.

## Anti Pattern

Reading a setup-derived or dependency-derived value and asserting on it without seeding state first. Combined with auto-stubs returning defaults, this produces a green or red result that reflects test plumbing rather than the behaviour under test. The signal in review: an assertion whose expected value depends on data the test never explicitly arranged.
