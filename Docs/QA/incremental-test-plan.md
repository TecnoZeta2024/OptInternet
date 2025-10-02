# Incremental Test Plan

**Goal:** Introduce automated testing in stages that align with the modernization roadmap, ensuring coverage grows in tandem with refactoring milestones.

## Phase 1 (Foundation)

| Week | Focus                      | Test Artifacts                                                                                              | Owners            |
| ---- | -------------------------- | ----------------------------------------------------------------------------------------------------------- | ----------------- |
| 1    | Runspace PoC               | Console harness smoke test (`RunspaceHarnessTests.cs`) validating ≥1 PS invocation                          | Platform Engineer |
| 2    | MonitoringService skeleton | xUnit project targeting MonitoringService state transitions (Start/Stop/Pause) with mocked PowerShellBridge | QA Lead           |
| 3    | PowerShell module smoke    | Pester tests covering `Test-InternetConnection`, `Get-NetworkMetrics`, `Restart-InternetAdapter`            | PowerShell SME    |
| 4    | Integration pipeline       | GitHub Actions workflow running console harness + Pester suite on PR                                        | DevOps            |

## Phase 2 (Feature Parity)

| Sprint | Focus                   | Test Artifacts                                                                          | Owners            |
| ------ | ----------------------- | --------------------------------------------------------------------------------------- | ----------------- |
| 5      | Profile management      | Unit tests for ConfigurationService (load/save/validate) + JSON schema validation tests | QA Lead           |
| 6      | UI binding              | UI automation smoke (WinAppDriver/Playwright) verifying metric cards + charts refresh   | UI QA             |
| 7      | Logs & ExecutionConsole | Integration test simulating 5k log entries ensuring buffer rotation                     | Platform Engineer |
| 8      | Hotspot controls        | PowerShell integration tests w/ mocked adapters + contract tests in MonitoringService   | QA Lead           |

## Phase 3 (Enhancement)

| Sprint | Focus          | Test Artifacts                                                          | Owners  |
| ------ | -------------- | ----------------------------------------------------------------------- | ------- |
| 10     | Update service | Integration tests for update download/verify (use fixture server)       | DevOps  |
| 11     | Theming        | Snapshot/UI tests validating Light/Dark resource dictionaries           | UI QA   |
| 12     | Export reports | Unit/integration tests covering CSV/HTML export, sample data comparison | QA Lead |

## Quality Gates

- **CI Requirements (Phase 1 onwards):** Console harness smoke + Pester unit tests must pass on every PR
- **CI Requirements (Phase 2 onwards):** Add MonitoringService unit suite and ConfigurationService validation
- **Release Criteria:** All P0/P1 tests green, UI automation suite (smoke) passing, performance baseline within ±5 % of targets

## Tooling & Infrastructure

- Test frameworks: xUnit (.NET), Pester (PowerShell), WinAppDriver/Playwright for UI
- CI: GitHub Actions with matrix (Windows 10/11)
- Artifacts: Publish test results + code coverage to `Artifacts/test-results/`

## Next Steps

1. Create test project skeletons (`tests/OptiGemini.Tests`, `tests/OptiGemini.PowerShell.Tests`)
2. Author initial smoke tests aligned with Week 1 objectives
3. Configure GitHub Actions workflow (`.github/workflows/ci.yml`) to execute tests on push/PR