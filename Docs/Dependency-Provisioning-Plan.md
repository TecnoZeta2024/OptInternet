# Dependency Provisioning Plan

This plan documents how to acquire, configure, and maintain the external services and libraries required for the OptiGemini v3.0 modernization. It closes gaps identified in the PO master checklist (Section 3).

## 1. Distribution & Update Channels

| Dependency                | Owner         | Actions                                                                                                  | Notes                                   |
| ------------------------- | ------------- | -------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| **GitHub Releases**       | Product Owner | Create repository release plan, enable release notes template, configure branch protection for `main`    | Required for MSI + auto-update payloads |
| **WinGet Manifest**       | DevOps        | Register Windows Package Manager publisher (free), prepare manifest PR targeting `microsoft/winget-pkgs` | Follow Microsoft submission checklist   |
| **Squirrel.Windows Feed** | DevOps        | Configure GitHub Releases for delta packages, ensure release assets <2 GB                                | No extra account; uses GitHub tokens    |

## 2. Code Signing (Future Enhancement)

| Step                                                        | Responsible   | Timing   |
| ----------------------------------------------------------- | ------------- | -------- |
| Evaluate certificate providers (DigiCert, SSL.com, Sectigo) | Product Owner | Post-MVP |
| Budget approval (~USD $100/year)                            | Product Owner | Post-MVP |
| Configure Azure Key Vault or local HSM for secure storage   | DevOps        | Post-MVP |

*MVP proceeds unsigned, but documentation must include SmartScreen guidance (see `Docs/Communications/admin-requirements-plan.md`).*

## 3. Application Libraries (NuGet)

| Package                            | Purpose                      | Version Strategy                          | Notes                                 |
| ---------------------------------- | ---------------------------- | ----------------------------------------- | ------------------------------------- |
| `MaterialDesignThemes`             | Windows 11-styled components | Pin to latest minor in 5.x series         | Supports both light/dark themes       |
| `MaterialDesignColors`             | Palette resources            | Align with `MaterialDesignThemes` version | Required for design tokens            |
| `LiveChartsCore.SkiaSharpView.WPF` | Real-time charts             | Pin to stable 2.x release                 | Validate performance at 2 Hz sampling |
| `Newtonsoft.Json`                  | Config/profile persistence   | Pin to 13.0.x LTS                         | Ensure deterministic serialization    |
| `System.Management.Automation`     | PowerShell hosting           | Use Microsoft. PowerShell SDK 7.4.x       | Keep consistent with runtime version  |

**Provisioning:**
- Add packages via `dotnet add package` to the future WPF project.
- Mirror versions into `Directory.Packages.props` (TBD) for central management.
- Track license compliance in `Docs/Architecture/tech-stack.md` once the component list is final.

## 4. PowerShell Module Packaging

- Convert `OpTinternet.ps1` into `Modules/OptiGemini.psm1` (already referenced by runspace PoC).
- Publish internal gallery (optional) using `Save-Module` if multiple projects consume it.
- Maintain module manifest (`OptiGemini.psd1`) capturing version, author, and required modules (none currently).

## 5. Telemetry & Analytics

| Service                  | Decision | Actions                                                                                       |
| ------------------------ | -------- | --------------------------------------------------------------------------------------------- |
| **Application Insights** | Defer    | Evaluate after MVP once telemetry opt-in flow designed                                        |
| **Local Telemetry**      | MVP      | Implement JSON log exports in `%APPDATA%/OptiGemini/logs/` (existing scripts already support) |
| **Privacy**              | MVP      | Document opt-in toggle and anonymization in Settings UI                                       |

## 6. Notification Channels

- **Windows Toast Notifications:** Uses built-in Windows APIs; no external provisioning required.
- **Email/SMS Alerts (future):** Evaluate free tier providers (SendGrid, Twilio) post-MVP if remote alerts requested.

## 7. Credential Management

- Store updater access tokens and future signing certificates inside Azure Key Vault or GitHub Actions secrets (`CodeSigningCert`, `WinGetToken`).
- Use Windows Credential Locker for end-user stored secrets (see PRD NFR-08).
- Document rotation schedule (quarterly) once secrets introduced.

## 8. Verification Checklist

| Task                                     | Owner                  | Target          | Status |
| ---------------------------------------- | ---------------------- | --------------- | ------ |
| GitHub release workflow documented       | Product Owner          | Phase 1 Week 4  | ☐      |
| WinGet publisher registration submitted  | DevOps                 | Phase 3 Week 10 | ☐      |
| NuGet dependencies pinned in WPF project | Developer              | Phase 1 Week 2  | ☐      |
| Credential storage strategy ratified     | Product Owner & DevOps | Phase 2 Week 7  | ☐      |

Keep this plan updated as new services or libraries are introduced.