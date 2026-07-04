---
bc-version: [all]
domain: error-handling
keywords: [job-queue, background-session, heartbeat, self-heal, recurring, dispatcher, unattended, codeunit-run, recovery]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A recurring job queue entry must never error, and should self-heal

## Description

End users do not know the Job Queue exists, never open the Job Queue Entries page, and cannot recover a stopped entry. So a recurring background job that relies on the entry's own status for reliability is fragile: when a run errors past its retry count the platform parks the entry in `Error` or `On Hold`, background processing silently stops, and nobody notices until data is missing. LLMs routinely generate exactly this shape — an install codeunit that inserts a recurring entry once, with the real work called directly in `OnRun` and no recovery — so this guidance is remedial. The reliable pattern separates three concerns the naive version fuses: the entry must stay healthy on its own, failures must be contained and recorded out-of-band, and the entry must be re-created or reset without a human.

## Best Practice

Run one recurring "heartbeat" entry that targets a thin dispatcher codeunit; let the dispatcher decide what is actually due (drive per-task cadence from a state row, not from many entries). Make the dispatcher incapable of erroring: run each unit of work through `Codeunit.Run` (or a codeunit variable's `Run`) so a failure rolls back only that unit and returns `false`, then record the failure in your own durable log/state table and, if warranted, alert an administrator by e-mail (the platform Notification e-mail scenario works from a background session; in-client notifications do not). Because the dispatcher never raises, the entry stays `Ready`. Add a self-heal routine that re-creates the entry when missing and resets it from `Error`/`On Hold` to `Ready`; invoke it at install/upgrade and on company open (`System Initialization.OnAfterInitialization`), throttled to at most hourly via a stored timestamp, from interactive sessions only, elevated with the codeunit `Permissions` property, and under an update lock so simultaneous logins cannot create duplicates. Invisible to end users does not mean invisible to everyone: an administrator must still get a signal for a persistent failure, throttled by a consecutive-failure count so a broken task does not e-mail every run.

## Anti Pattern

An install codeunit that inserts a recurring entry with `Insert(false)` and swallows the result, whose target codeunit does the real work inline in `OnRun` with no `Codeunit.Run` isolation. One bad record errors the run; after the retry count the entry parks in `Error`; background processing stops with no log, no alert, and no recovery, and the only fix is a user opening the Job Queue Entries page — which never happens. A second smell is "self-healing" that blindly resets an errored entry on a hot event (per record read or every login), which hammers the job queue tables, can deadlock the dispatcher, and can mask a genuinely permanent failure in an infinite silent-retry loop. Detection: a recurring `Job Queue Entry` whose `Object ID to Run` codeunit calls its work directly without a captured `Codeunit.Run`, with no accompanying log/state table; or job queue recovery logic subscribed to a high-frequency event or with no consecutive-failure cap and no admin alert.
