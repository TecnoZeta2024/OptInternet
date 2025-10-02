# Admin Privileges Communication Plan

**Purpose:** Ensure users understand why OptiGemini requires elevated privileges, how to proceed safely, and what functionality is available without admin access.

## Key Messages

1. 📌 **Why admin is needed:** Network adapter resets, DNS changes, hotspot management, and registry optimizations.
2. 🔒 **Security assurances:** Actions limited to documented network operations; no data exfiltration.
3. 🛠️ **Limited mode:** Monitoring-only mode is available when run without admin rights.
4. 📝 **Consent:** Users can opt in during first-run onboarding with clear summary of operations.

## Communication Channels

| Channel           | Touchpoint                              | Content Owner     | Status   |
| ----------------- | --------------------------------------- | ----------------- | -------- |
| Installer         | MSI first-run screen                    | Product Owner     | Drafting |
| In-App Onboarding | Welcome wizard + tooltip on status card | UX Writer         | Drafting |
| Documentation     | README, FAQ, troubleshooting guide      | Technical Writer  | Drafting |
| Release Notes     | v3.0 launch notes                       | Product Marketing | Planned  |
| Support           | Canned responses for helpdesk           | Support Lead      | Planned  |

## Deliverables

- **Onboarding Modal Copy:** Explain required privileges + limited mode toggle.
- **FAQ Section:** “Why does OptiGemini need administrator rights?” with steps to switch modes.
- **Notification Copy:** Toast when app downgrades to monitoring mode due to missing elevation.
- **Release Note Entry:** Highlight new limited mode feature.

## Timeline

| Week | Milestone                               |
| ---- | --------------------------------------- |
| 2    | Draft copy reviewed by legal/compliance |
| 3    | UX integration in onboarding wizard     |
| 4    | Publish documentation + FAQ updates     |

## Dependencies

- Availability of limited mode implementation (MonitoringService supporting read-only operations).
- Input from security team on wording and best practices.

## Risk Mitigation Links

- Addresses **Risk R3** (Admin privilege friction) from `Docs/Architecture-Summary.md`.
- Connected backlog item: `BL-007` in `Docs/Backlog.md`.