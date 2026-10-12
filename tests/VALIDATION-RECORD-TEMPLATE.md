# Validation record template

Copy to a dated record when tests are performed. A successful package build alone is not runtime evidence.

## Provenance

- Date/time, timezone and tester:
- PR, base/head refs and commit SHA:
- Working-tree dirty state (attach diff if dirty):
- Workflow URL and event/ref (including merge SHA if applicable):
- Artifact name, package identity/version and SHA-256:
- EXE/DLL hashes for standalone/local builds:
- Windows edition/version, OS build and architecture:
- .NET SDK, MSVC and Windows SDK versions for local builds:
- Display scaling, monitors and input/accessibility setup:
- Existing Store/dev/NSIS installs and authorization for the test environment:

## Results

Use PASS / FAIL / BLOCKED / NOT RUN with logs or screenshots. Include every item from the applicable plan; extend the table as needed.

| Case / plan item | Result | Evidence and observations |
|---|---|---|
| Build and artifact integrity | NOT RUN | |
| Core hardening: dimensions, DPI, source hashes, naming, Unicode, batch, invalid PDFs, cleanup | NOT RUN | |
| MSIX install and both Explorer verbs | NOT RUN | |
| One-page and multi-page PNG/JPG | NOT RUN | |
| Progress delay, current-PDF percentage and batch counters | NOT RUN | |
| Cancel during render, encode, finalization; preserve completed output | NOT RUN | |
| Window close/Alt+F4, keyboard and display scaling | NOT RUN | |
| Errors and subsequent batch files | NOT RUN | |
| Uninstall, menu removal and exact dev certificate cleanup | NOT RUN | |
| No leftover temporary files or conversion processes | NOT RUN | |

## Decision

- Applicable plans and their versions/SHAs:
- Failures, untested cases and follow-up issues:
- Overall result and compatibility scope established:
- Maintainer approval / release decision (separate from test result): PENDING

Use repository fixtures rather than private customer documents in shared evidence. Avoid exposing private paths or document contents in screenshots/logs.
