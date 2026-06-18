---
bc-version: [all]
domain: testing
keywords: [testability, interface, dependency-injection, event-subscriber, container-less, al-runner]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Design AL logic so it can be tested without a container

## Description

Whether logic can be exercised by a container-less runner like AL Runner is decided at design time, not test time. The runner can only call your own `.al` code, and it cannot make base-application events fire. Code that does real work *inside* an event subscriber body, or that calls hard dependencies directly, is unreachable from a fast unit test. Code that keeps its decision logic in plain public procedures, and receives its external collaborators through AL interfaces, is fully testable in milliseconds — and is cleaner regardless of the test tool.

## Best Practice

Keep event subscribers thin: have the subscriber extract what it needs and delegate to a public `procedure` that contains the real logic, then unit-test that procedure directly. Inject anything that crosses an app boundary or touches an unsupported subsystem (HTTP, another app's codeunit) through an `interface` parameter, so a test can supply a controlled implementation. Anything you cannot inject cannot be unit-tested by the runner — and that is the correct boundary.

See sample: `design-al-logic-for-container-less-tests.good.al`.

## Anti Pattern

Burying business logic in the body of an `[EventSubscriber]` that fires off a base-application table or codeunit event, or calling a dependency codeunit directly from inside that body. The container-less runner cannot trigger the base-app event and auto-stubs the dependency, so the logic is untestable without a full BC service tier. The detection signal in review: meaningful branching, calculation, or validation that lives directly in a subscriber rather than in a separately callable procedure.

See sample: `design-al-logic-for-container-less-tests.bad.al`.
