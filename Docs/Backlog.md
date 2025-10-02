# OptiGemini Risk Mitigation Backlog

| ID     | Title                                     | Description                                                                                                             | Owner             | Priority | Target Phase   | Status  |
| ------ | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------- | -------- | -------------- | ------- |
| BL-001 | Implement PowerShell runspace watchdog    | Build watchdog with heartbeat + auto-restart and telemetry to mitigate R1 (runspace instability).                       | Architecture Lead | P0       | Phase 1 Week 1 | Planned |
| BL-002 | Optimize WPF streaming performance        | Profile LiveCharts2 + ExecutionConsole at 2 Hz, implement batching/virtualization to address R2.                        | UI Engineer       | P0       | Phase 1 Week 2 | Planned |
| BL-003 | Admin privilege UX messaging              | Detect privileges on startup and surface modal/tooltips explaining limited mode to mitigate R3.                         | Product Owner     | P1       | Phase 1 Week 3 | Planned |
| BL-004 | PowerShell ↔ C# integration tests         | Add integration test suite covering critical PS functions (Test-InternetConnection, Get-NetworkMetrics) to mitigate R8. | QA Lead           | P0       | Phase 1 Week 2 | Planned |
| BL-005 | Configuration validation & backups        | Add JSON schema validation and auto-backup when saving profiles/settings to mitigate R5.                                | Platform Engineer | P1       | Phase 2 Week 1 | Planned |
| BL-006 | Performance telemetry baseline            | Instrument metrics (latency, CPU, FPS) and dashboards to monitor R2/R10.                                                | DevOps            | P1       | Phase 1 Week 4 | Planned |
| BL-007 | Communication plan for admin requirements | Draft onboarding copy, release notes, and FAQ around admin needs (ties to R3).                                          | Product Marketing | P1       | Phase 1 Week 3 | Planned |

> **Note:** Backlog entries map to risk IDs documented in `Docs/Architecture-Summary.md` and `Docs/Architecture/brownfield-architecture.yaml`.