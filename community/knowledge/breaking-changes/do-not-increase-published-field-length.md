---
bc-version: [all]
domain: breaking-changes
keywords: [field-length, text, code, breaking-change, as0086, as0080, as0118, schema, dependent-extension]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Increasing the length of a published table field is a breaking change

## Description

The intuition that "enlarging a text field is safe, only shrinking is destructive" is wrong for published apps. It is half-true: the database **Synchronize** engine does allow widening a `Text`/`Code` field (for example `Text[32]` to `Text[87]`) as a non-destructive column change, which is why it works in a quick on-prem F5 test. But AppSourceCop blocks it as a breaking change because a *dependent extension* compiled against the old length can assign the field into a shorter variable and hit a runtime truncation or exception. The relevant rules: `AS0086` flags increasing length, `AS0080` flags decreasing length, and `AS0118` covers length changes on a field that is part of the primary key (breaks the sync engine outright). Both directions are reported under the Upgrade category, so a length change on an already-published field is never a clean, compatible edit.

## Best Practice

Treat the length of any published field as fixed. When more capacity is genuinely needed, do not edit the existing field's length — add a **new** field with the larger size and migrate, or follow the documented two-step lifecycle: mark the field `ObsoleteState = Pending`, ship that, then in a later version remove the `Pending` state and change the length once dependents have moved off it. Fields that have never been published (added in the current, not-yet-released version) have no previous version to compare against, so they can be sized freely — choose the right length up front to avoid the problem entirely.

See sample: `do-not-increase-published-field-length.good.al`.

## Anti Pattern

Widening an existing published field in place — `field(7; "Electronic Service Address"; Text[50])` becoming `Text[100]` in the next version — on the assumption that "enlarge is non-destructive". It may sync cleanly for a standalone app, but it trips AS0086 and can break dependent extensions and AppSource validation.

See sample: `do-not-increase-published-field-length.bad.al`.
