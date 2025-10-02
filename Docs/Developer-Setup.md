# Developer Environment Setup

This guide captures the minimum steps required to get a contributor workstation ready to extend OptiGemini v3.0. It complements the PRD and architecture references by providing a concrete checklist for local onboarding.

## 1. Host Platform

- **Operating System:** Windows 11 23H2 (preferred) or Windows 10 21H2+ with latest updates.
- **Privileges:** Local administrator account (required for network adapter operations and registry optimization).
- **Hardware Baseline:** Quad-core CPU, 8 GB RAM, wired Ethernet adapter for reproducible testing.

## 2. Required Software

| Tool               | Version                                      | Purpose                             | Verification       |
| ------------------ | -------------------------------------------- | ----------------------------------- | ------------------ |
| PowerShell         | 7.4 LTS                                      | Runspace host for refactored module | `pwsh -v`          |
| .NET SDK           | 7.0.x                                        | Build/run WPF host + runspace PoC   | `dotnet --version` |
| Visual Studio 2022 | 17.8+ (Desktop development with C# workload) | IDE + XAML designer                 | Help → About       |
| Windows App SDK    | 1.5+ (optional)                              | Upcoming WinApp/WinUI experiments   | Installed apps     |
| Git                | 2.45+                                        | Source control                      | `git --version`    |
| Node.js + npm      | 18.x / 9.x (optional)                        | BMAD tooling helpers                | `node -v`          |

> ✅ **Tip:** Enable Developer Mode in Windows Settings to simplify sideloading and symbolic link creation.

## 3. Repository Bootstrap

1. Fork or clone the repository:
   ```pwsh
   git clone https://github.com/TecnoZeta2024/OptInternet.git
   cd OptInternet
   ```
2. Configure Git options recommended by BMAD:
   ```pwsh
   git config core.autocrlf true
   git config core.eol crlf
   ```
3. (Optional) Configure the backup mirror remote defined in `Docs/Git-Flow-Backup-Plan.md`:
   ```pwsh
   git remote add backup <mirror-url>
   git remote set-url --push backup <mirror-url>
   ```
   > Replace `<mirror-url>` with your approved mirror target (e.g., secondary GitHub repo, NAS bare repo).
4. Restore .NET dependencies for the runspace PoC:
   ```pwsh
   dotnet restore .\pocs\runspace\OptiGemini.RunspacePoC\OptiGemini.RunspacePoC.csproj
   ```
5. (Optional) Install BMAD CLI helpers if not already available:
   ```pwsh
   npm install -g bmad-method
   ```

## 4. Smoke Validation

Run the existing proof-of-concept harness to confirm the PowerShell ↔ .NET bridge works:

```pwsh
pwsh -NoProfile -Command "Get-ChildItem .\pocs\runspace\Modules"
dotnet run --project .\pocs\runspace\OptiGemini.RunspacePoC\OptiGemini.RunspacePoC.csproj --configuration Release
```

Expected outcome: 20 runspace invocations complete with <100 ms average round-trip (per runspace plan). Capture the console output in `Artifacts/runspace/` for future baselines.

## 5. PowerShell Policy Configuration

Allow scripts inside the repo to execute during development:

```pwsh
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> ℹ️ Production distribution will ship signed binaries; keep policy scoped to the current user only.

## 6. Local Path Conventions

- Keep the repo path free of spaces (e.g. `C:\dev\OptInternet`) to avoid quoting issues.
- All generated artifacts (`Artifacts/`, `bin/`, `obj/`) remain untracked; confirm `.gitignore` is respected.
- Use `%APPDATA%\OptiGemini\` for configuration and profile experiments to mirror runtime behaviour.

## 7. Optional Tooling Enhancements

- **Terminal:** Windows Terminal with PowerShell 7 profile.
- **Profiling:** Windows Performance Analyzer + Visual Studio Profiler for WPF frame-time validation.
- **Network Simulation:** `Clumsy`, `NetEm` (WSL) or `psping` for latency/packet-loss injection tests.

## 8. Next Steps Checklist

| Item                                              | Status |
| ------------------------------------------------- | ------ |
| Clone repository and configure Git                | ☐      |
| Install required runtimes (PowerShell 7 / .NET 7) | ☐      |
| Run runspace PoC (Release build)                  | ☐      |
| Capture baseline metrics (latency, CPU usage)     | ☐      |
| Configure `%APPDATA%` sandbox for profiles        | ☐      |
| Confirm admin privileges and execution policy     | ☐      |
| Mirror repository to backup remote                | ☐      |

When the checklist is complete, proceed to story intake and follow the Enhanced IDE Development Workflow.