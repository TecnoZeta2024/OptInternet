# Rollback & Feature Flag Strategy

This document operationalizes the rollback requirements highlighted in `Docs/Architecture/brownfield-architecture.yaml` (§rollback_strategy) and the PRD (FR-11). It ensures every brownfield integration includes a clear escape hatch.

## 1. Guiding Principles

1. **Reversibility First:** Every deployment must allow returning to the last known-good PowerShell-only experience within 5 minutes.
2. **Scoped Blast Radius:** Introduce new capabilities behind flags to disable faulty surfaces without uninstalling the app.
3. **Telemetry-Driven Decisions:** Trigger rollbacks based on observed metrics (latency, crash rate, watchdog restarts) exceeding thresholds.

## 2. Feature Flag Matrix

| Flag                           | Default | Scope             | Description                                                                                                    | Rollback Action                                        |
| ------------------------------ | ------- | ----------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `Gui.Dashboard.Enabled`        | ON      | Application-level | Toggles WPF dashboard; OFF reverts to console launch shortcut that opens PowerShell UI                         | Provide shortcut to `OpTinternet.ps1` fallback         |
| `Gui.ExecutionConsole.Enabled` | ON      | View-level        | Allows docking console stream; OFF hides panel and suppresses runspace event streaming                         | Disable WPF bindings; continue logging to file         |
| `Engine.Runspace.Hosted`       | ON      | Service-level     | Controls whether MonitoringService hosts PowerShell runspace; OFF launches external `pwsh.exe` similar to v2.2 | Spawn background PowerShell with same arguments        |
| `Engine.DnsOptimizer.Enabled`  | ON      | Engine-level      | Allows automated DNS switching; OFF reuses current adapter settings                                            | Use existing script branch that skips `Set-FastestDNS` |
| `Notifications.Toast.Enabled`  | ON      | UX-level          | Enables Windows toast; OFF logs notifications only                                                             | Avoid user interruptions during incident               |

Flags will be backed by a JSON config stored in `%APPDATA%/OptiGemini/config.json` and surfaced in the Settings UI (Advanced tab).

## 3. Release Package Strategy

| Scenario                     | Action                                                                                                |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| Minor GUI bug                | Toggle relevant feature flag via Settings UI or config hot reload                                     |
| Runspace instability         | Flip `Engine.Runspace.Hosted` to OFF, restart app → fall back to external PowerShell process          |
| Deployment regression        | Redeploy previous MSI from GitHub Releases; maintain last two stable builds                           |
| Critical failure post-update | Use Squirrel-generated `RELEASES` file to force rollback (`--releasify` provides prior delta package) |

## 4. Rollback Playbook

1. **Detect:** MonitoringService watchdog exceeds 3 restarts/hour **OR** telemetry flags >5% crash rate.
2. **Decide:** Triage severity; if P0/P1, initiate rollback immediately.
3. **Execute:**
   - Disable relevant feature flag(s) via `%APPDATA%/OptiGemini/config.json`.
   - If failure persists, download previous MSI from GitHub Releases page and install with `/passive` to preserve settings.
   - Announce rollback in release notes and README hotfix section.
4. **Validate:** Confirm metrics return to baseline; run regression suite (Pester + xUnit) locally.
5. **Document:** File incident report in `Docs/QA/gates/` with root cause and remediation plan.

## 5. Configuration Management

- Implement configuration snapshots: copy `%APPDATA%/OptiGemini/config.json` to `%APPDATA%/OptiGemini/backups/config-{timestamp}.json` before each save (ties to backlog BL-005).
- Provide CLI flag `--disable-flags=<comma list>` for emergency headless toggling.
- Log every flag change (`Write-Information` + telemetry event) for audit trail.

## 6. Testing Requirements

- **Unit Tests:** Ensure each flag toggles behaviour consistently (e.g., injection via `IOptionsSnapshot`).
- **Integration Tests:** Simulate toggling `Engine.Runspace.Hosted` during runtime to verify graceful restart.
- **Acceptance Tests:** Document manual rollback scenario in QA incremental plan (Phase 2 sprint 7).

## 7. Ownership & Communication

| Activity                   | Owner             | Channel                                                     |
| -------------------------- | ----------------- | ----------------------------------------------------------- |
| Feature flag governance    | Product Owner     | Weekly planning review                                      |
| Rollback drill (quarterly) | DevOps + QA       | Schedule via Teams; capture notes in `Docs/QA/assessments/` |
| User-facing communication  | Product Marketing | Release notes, FAQ updates                                  |

Maintain this document alongside architectural refreshes to keep rollback paths aligned with new capabilities.