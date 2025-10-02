# PowerShell Runspace PoC Plan

**Objective:** Validate stable, low-latency integration between the refactored `OpTinternet.ps1` module and a .NET 7 WPF host, de-risking R1 (runspace instability) before committing to full migration.

## Scope

- Prototype console app (Week 1) and lightweight WPF host (Week 2) invoking key PowerShell functions
- Measure round-trip latency, detect hangs, and validate parallel invocation scenarios
- Capture telemetry for success/failure events and resource usage

## Success Criteria

1. ✅ Create .NET 7 console harness that:
   - Initializes a dedicated runspace using `System.Management.Automation`
   - Imports the existing script/module (temporary stub acceptable)
   - Invokes `Test-InternetConnection` and `Get-NetworkMetrics` asynchronously
   - Achieves average round-trip latency ≤ 100 ms over 20 iterations
2. ✅ Implement watchdog timer detecting stalled runspace (timeout 30 s) and auto-restarting it
3. ✅ Surface telemetry (EventSource + log file) for: invocation duration, exceptions, restart count
4. ✅ Document findings + code snippets for reuse in MonitoringService implementation

## Work Breakdown

| Step | Description                                                                                                  | Owner             | ETA   |
| ---- | ------------------------------------------------------------------------------------------------------------ | ----------------- | ----- |
| 1    | Stub PowerShell module exporting `Test-InternetConnection` & `Get-NetworkMetrics` with deterministic outputs | Platform Engineer | Day 1 |
| 2    | Build .NET console harness (`OptiGemini.RunspacePoC`) referencing `System.Management.Automation`             | Platform Engineer | Day 1 |
| 3    | Implement async invocation wrapper + cancellation tokens                                                     | Platform Engineer | Day 2 |
| 4    | Add watchdog service (timer + auto-restart)                                                                  | Platform Engineer | Day 2 |
| 5    | Collect metrics across 100 invocations, log results                                                          | QA Support        | Day 3 |
| 6    | Draft technical note summarizing latency graph + recommendations                                             | Architect         | Day 3 |

## Telemetry & Instrumentation

- Use `EventSource` with events: `RunspaceInvokeStart`, `RunspaceInvokeCompleted`, `RunspaceRestarted`, `RunspaceFault`
- Persist summary metrics to `Artifacts/runspace-poc/metrics.json`
- Optional: capture per-invocation duration percentiles (P50/P95/P99)

## Risks & Mitigations

- **Risk:** Stub PowerShell functions diverge from real behavior → Mitigation: swap in real functions once module refactor available and re-run tests
- **Risk:** Watchdog restarts cause resource leaks → Mitigation: ensure `Runspace.Dispose()` is called, monitor process memory growth

## Deliverables

- Repository folder `pocs/runspace/` with console project + README
- Metrics report (`pocs/runspace/RESULTS.md`) documenting latency, failure rate, restart events
- Recommendations integrated into MonitoringService design doc