# Runspace PoC

Prototype harness validating the PowerShell ⇆ .NET integration for OptiGemini before wiring it into the production MonitoringService.

## Project layout

```
pocs/runspace/
├── README.md
├── OptiGemini.RunspacePoC/
│   ├── OptiGemini.RunspacePoC.csproj
│   ├── Program.cs
│   ├── RunspaceHarness.cs
│   ├── RunspaceWatchdog.cs
│   └── Telemetry/EventIds.cs
└── Modules/
    └── OptiGemini.psm1
```

## Prerequisites

- .NET 7 SDK
- PowerShell 7.x (for the stub module execution)

## Quick start

```pwsh
cd pocs/runspace/OptiGemini.RunspacePoC
dotnet run --configuration Release
```

The harness will:

1. Create a dedicated PowerShell runspace
2. Import the stub module located in `../Modules/OptiGemini.psm1`
3. Invoke `Test-InternetConnection` and `Get-NetworkMetrics` 20 times
4. Emit telemetry (console + JSON) showing latency statistics and watchdog restarts

Output artifacts are written to `pocs/runspace/artifacts/`.

## Next steps

- Swap the stub module for the refactored `OpTinternet.psm1` once available
- Integrate results into MonitoringService design
- Extend telemetry to publish EventSource traces for tooling integration