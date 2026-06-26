---
bc-version: [all]
domain: performance
keywords: [setfilter, wildcard, placeholder, substitution, filter, strsubstno, contains]
technologies: [al]
countries: [w1]
application-area: [all]
---

# SetFilter does not reliably substitute `%1` when the format string also contains wildcards

## Description

`Record.SetFilter(Field, '@*%1*', Value)` reads as a case-insensitive "contains" search, and the obvious expectation is that `%1` is replaced by `Value`. It is not always so: when the format string combines a wildcard (`*` or `?`) with a token placeholder, the platform can skip the substitution and apply the **literal** filter `@*%1*`. The filter then searches for the two characters `%1` and matches nothing — a silent wrong-results bug, not a compile error. The give-away is in the debugger: the record's applied filter shows `Field: @*%1*` instead of the substituted value. This is a long-standing platform quirk (see microsoft/AL issue 7283); plain `SetFilter(Field, '%1', Value)` without wildcards substitutes correctly, which is what masks the problem.

## Best Practice

Build the wildcard filter string with `StrSubstNo` first, then pass the finished string as the single filter argument: `SetFilter(Field, StrSubstNo('@*%1*', Value))`. `StrSubstNo` always performs the substitution, so the applied filter becomes `@*<value>*` with the wildcards intact. When the search is an exact, full-value lookup (a pasted USI, a complete ABN), prefer `SetRange(Field, Value)` — it needs no wildcards or placeholders and sidesteps the issue entirely. Note that `StrSubstNo` substitutes the value but does not escape filter operators, so when `Value` is free text that may contain `&`, `|`, or `(`, sanitize it for the contexts where a malformed filter matters.

See sample: `setfilter-wildcard-needs-strsubstno.good.al`.

## Anti Pattern

Passing the value as a `SetFilter` token argument while the format string carries wildcards — `SetFilter(Name, '@*%1*', SearchText)`. It compiles, looks correct in review, and works in the simplest manual test, but on the affected platform builds it applies a literal `@*%1*` and the lookup quietly returns nothing.

See sample: `setfilter-wildcard-needs-strsubstno.bad.al`.
