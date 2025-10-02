# MSI Installer Test Plan

## Overview
This document outlines the testing strategy for the OptiGemini MSI installer, covering manual and automated tests.

## Test Environments

### Required Test Platforms
1. **Windows 11 23H2** (Primary target)
   - Clean VM or physical machine
   - With and without prerequisites installed

2. **Windows 10 21H2** (Minimum supported version)
   - Clean VM or physical machine
   - With and without prerequisites installed

### Test Prerequisites Status Matrix
| Test Scenario | .NET 7 Desktop Runtime | PowerShell 7.4+ | Expected Behavior |
|--------------|------------------------|-----------------|-------------------|
| Scenario A   | ✓ Installed            | ✓ Installed     | Full installation |
| Scenario B   | ✗ Not installed        | ✓ Installed     | Prompt for .NET, abort if declined |
| Scenario C   | ✓ Installed            | ✗ Not installed | Warning, continue with limited mode |
| Scenario D   | ✗ Not installed        | ✗ Not installed | Prompt for .NET first, then PowerShell |

## Test Cases

### TC-001: Clean Installation (Full Prerequisites)
**Priority**: P0 (Critical)  
**Environment**: Scenario A  
**Steps**:
1. Double-click `OptiGemini.msi`
2. Follow installation wizard
3. Accept license agreement
4. Choose installation directory (default: `C:\Program Files\OptiGemini`)
5. Select "Create Desktop Shortcut" option
6. Click Install
7. Wait for completion
8. Click Finish

**Expected Results**:
- Installation completes without errors
- Exit code: 0
- Files installed to `C:\Program Files\OptiGemini\`:
  - `bin\OptiGemini.RunspacePoC.exe`
  - `bin\OptiGemini.RunspacePoC.dll`
  - `bin\System.Management.Automation.dll`
  - `Modules\OptiGemini.psm1`
  - `default-config.json`
- Start Menu shortcut created: `Start Menu\Programs\OptiGemini\OptiGemini.lnk`
- Desktop shortcut created (if selected)
- Registry keys created:
  - `HKLM\Software\TecnoZeta\OptiGemini\InstallPath`
  - `HKLM\Software\TecnoZeta\OptiGemini\Version`
- Installation log created: `%TEMP%\OptiGemini_Install.log`

**Pass Criteria**: All expected results verified ✓

---

### TC-002: Installation Without .NET Desktop Runtime
**Priority**: P0 (Critical)  
**Environment**: Scenario B  
**Steps**:
1. Ensure .NET Desktop Runtime 7.x is NOT installed
2. Double-click `OptiGemini.msi`
3. Observe prerequisite check dialog

**Expected Results**:
- Dialog appears: ".NET Desktop Runtime 7.0 or higher is required..."
- Dialog includes download URL: https://dotnet.microsoft.com/download/dotnet/7.0
- Options: "Yes" (opens download page), "No" (aborts installation)
- If "No" clicked: Installation aborts with exit code 1603
- If "Yes" clicked: Browser opens to download page, installation waits/aborts

**Pass Criteria**: Prerequisite detection works correctly, user is guided to download ✓

---

### TC-003: Installation Without PowerShell 7.4+
**Priority**: P1 (High)  
**Environment**: Scenario C  
**Steps**:
1. Ensure PowerShell 7.4+ is NOT installed
2. Double-click `OptiGemini.msi`
3. Observe PowerShell check dialog

**Expected Results**:
- Dialog appears: "PowerShell 7.4 or higher is recommended..."
- Dialog indicates limited mode is available
- Download URL shown: https://aka.ms/install-powershell-windows
- Options: "Yes" (opens download page), "No" (continues installation)
- Installation continues regardless of choice (non-blocking)

**Pass Criteria**: User is warned but not blocked, installation proceeds ✓

---

### TC-004: Application Launch After Installation
**Priority**: P0 (Critical)  
**Environment**: Scenario A  
**Steps**:
1. Complete TC-001 (Clean Installation)
2. Launch application from Start Menu shortcut
3. Verify application starts

**Expected Results**:
- Application launches without errors
- Main window appears (runspace PoC console output)
- No error dialogs
- Process visible in Task Manager: `OptiGemini.RunspacePoC.exe`

**Pass Criteria**: Application launches and runs for at least 30 seconds ✓

---

### TC-005: Clean Uninstallation
**Priority**: P0 (Critical)  
**Environment**: Post TC-001  
**Steps**:
1. Open "Add or Remove Programs"
2. Find "OptiGemini"
3. Click "Uninstall"
4. Confirm uninstallation
5. Wait for completion

**Expected Results**:
- Uninstallation completes without errors
- Application files removed from `C:\Program Files\OptiGemini\`
- Start Menu shortcut removed
- Desktop shortcut removed (if was created)
- Registry keys removed:
  - `HKLM\Software\TecnoZeta\OptiGemini` (deleted)
- Uninstallation log created: `%TEMP%\OptiGemini_Uninstall.log`

**Pass Criteria**: All files removed except profile backup ✓

---

### TC-006: Profile Backup During Uninstallation
**Priority**: P1 (High)  
**Environment**: Post TC-001, with user profiles created  
**Steps**:
1. Install OptiGemini (TC-001)
2. Create test profile files:
   - Create `%APPDATA%\OptiGemini\profiles\test-profile.json`
   - Add sample content
3. Uninstall via "Add or Remove Programs"
4. Check for backup

**Expected Results**:
- Dialog appears: "Your OptiGemini profiles have been backed up to: [path]"
- Backup file created: `%APPDATA%\OptiGemini\OptiGemini_Profiles_Backup_YYYYMMDD_HHMMSS.zip`
- Backup contains `test-profile.json`
- Profiles folder (`%APPDATA%\OptiGemini\profiles`) removed after backup

**Pass Criteria**: Profiles backed up successfully before removal ✓

---

### TC-007: Upgrade Installation
**Priority**: P1 (High)  
**Environment**: Scenario A, with v3.0.0 installed  
**Steps**:
1. Install OptiGemini v3.0.0
2. Build v3.0.1 MSI with incremented version
3. Install v3.0.1 MSI
4. Observe upgrade behavior

**Expected Results**:
- Installer detects existing version
- Old version removed automatically
- New version installed
- User settings/profiles preserved
- No duplicate entries in Programs and Features

**Pass Criteria**: Upgrade completes without manual uninstall ✓

---

### TC-008: Downgrade Prevention
**Priority**: P2 (Medium)  
**Environment**: Scenario A, with v3.0.1 installed  
**Steps**:
1. Install OptiGemini v3.0.1
2. Attempt to install v3.0.0 MSI

**Expected Results**:
- Error dialog: "A newer version of [ProductName] is already installed."
- Installation aborts
- Existing v3.0.1 remains installed

**Pass Criteria**: Downgrade blocked, user informed ✓

---

### TC-009: Silent Installation (Command Line)
**Priority**: P2 (Medium)  
**Environment**: Scenario A  
**Steps**:
```powershell
msiexec /i OptiGemini.msi /qn /l*v C:\Temp\silent_install.log
```

**Expected Results**:
- Installation completes without UI
- Exit code: 0
- All files installed correctly
- Log file created with detailed information

**Pass Criteria**: Silent installation works for automated deployments ✓

---

### TC-010: Installation to Custom Directory
**Priority**: P2 (Medium)  
**Environment**: Scenario A  
**Steps**:
1. Run installer
2. Click "Change" for installation directory
3. Select `D:\CustomApps\OptiGemini`
4. Complete installation

**Expected Results**:
- Application installed to custom directory
- Registry `InstallPath` reflects custom location
- Shortcuts point to correct custom location

**Pass Criteria**: Custom directory respected throughout ✓

---

## Automated Test Execution

### Local Testing
```powershell
# Build and run tests
.\build-installer.ps1 -Test

# Build, install, and test
.\build-installer.ps1 -Install -Test

# Clean, build, test
.\build-installer.ps1 -Clean -Test
```

### CI/CD Pipeline
Tests run automatically via GitHub Actions (`.github/workflows/build-msi.yml`):
- Build verification on every push
- Installation test on Windows Server 2022 runner
- Uninstallation validation
- Artifact retention for 30 days

## Manual Test Checklist

### Pre-Release Validation
- [ ] TC-001: Clean Installation (Win 11)
- [ ] TC-001: Clean Installation (Win 10)
- [ ] TC-002: Installation without .NET
- [ ] TC-003: Installation without PowerShell
- [ ] TC-004: Application Launch
- [ ] TC-005: Clean Uninstallation
- [ ] TC-006: Profile Backup
- [ ] TC-007: Upgrade Installation
- [ ] TC-008: Downgrade Prevention
- [ ] TC-009: Silent Installation
- [ ] TC-010: Custom Directory Installation

### Smoke Test (Quick Validation)
- [ ] Build MSI without errors
- [ ] Install on clean Windows 11 VM
- [ ] Launch application successfully
- [ ] Uninstall cleanly
- [ ] Check for orphaned files/registry keys

## Test Results Template

```markdown
## Test Execution Report

**Date**: YYYY-MM-DD  
**Tester**: [Name]  
**Build Version**: v3.0.0  
**Environment**: Windows 11 23H2 (Build 22631.xxxx)  

### Test Results Summary
| Test Case | Status | Notes |
|-----------|--------|-------|
| TC-001    | ✅ PASS | Installation successful |
| TC-002    | ✅ PASS | Prerequisite check working |
| TC-003    | ✅ PASS | Warning displayed correctly |
| TC-004    | ✅ PASS | Application launched |
| TC-005    | ✅ PASS | Uninstalled cleanly |
| TC-006    | ✅ PASS | Backup created |
| TC-007    | ⚠️ SKIP | Requires v3.0.1 build |
| TC-008    | ⚠️ SKIP | Requires v3.0.1 build |
| TC-009    | ✅ PASS | Silent install works |
| TC-010    | ✅ PASS | Custom directory works |

### Issues Found
1. **Issue #1**: [Description]
   - Severity: High/Medium/Low
   - Steps to reproduce: [...]
   - Expected: [...]
   - Actual: [...]

### Sign-Off
- [ ] All P0 tests passed
- [ ] All P1 tests passed or issues documented
- [ ] Installer ready for release
```

## Regression Testing
Run full test suite for:
- Major version releases (v3.0.0 → v4.0.0)
- Significant installer changes
- Windows OS updates
- WiX toolset upgrades

## Performance Benchmarks
| Metric | Target | Measurement |
|--------|--------|-------------|
| MSI file size | < 50 MB | [Actual] MB |
| Installation time | < 60 seconds | [Actual] seconds |
| Uninstallation time | < 30 seconds | [Actual] seconds |
| First launch time | < 5 seconds | [Actual] seconds |

## Known Limitations
1. Requires administrator privileges for installation
2. .NET Desktop Runtime 7.x is a hard requirement (blocks install if missing)
3. PowerShell 7.4+ is soft requirement (warns but continues)
4. No support for per-user installations (machine-wide only)
5. No support for Windows 8.1 or earlier

## References
- WiX Toolset Testing: https://wixtoolset.org/docs/v4/guides/testing/
- Windows Installer Best Practices: https://docs.microsoft.com/en-us/windows/win32/msi/installation-best-practices
