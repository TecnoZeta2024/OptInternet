# OptiGemini Desktop Application

## Prerequisites

- .NET 7.0 SDK or later
- Windows 10 21H2+ or Windows 11
- PowerShell 7.4+ (for PowerShell bridge functionality)

## Development Setup

### Install .NET SDK

Download and install from: https://dotnet.microsoft.com/download/dotnet/7.0

### Build the Application

```powershell
# From repository root
dotnet build src/OptiGemini.Desktop/OptiGemini.Desktop.csproj
```

### Run the Application

```powershell
# From repository root
dotnet run --project src/OptiGemini.Desktop/OptiGemini.Desktop.csproj
```

### Run Tests

```powershell
# From repository root
dotnet test tests/OptiGemini.Desktop.Tests/OptiGemini.Desktop.Tests.csproj
```

## Project Structure

```
src/
  OptiGemini.Desktop/          # Main WPF application
    Commands/                   # ICommand implementations
    Models/                     # Data models and enums
    PowerShell/                 # PowerShell runspace integration
    Resources/                  # XAML resources (colors, styles)
    Services/                   # Application services
    ViewModels/                 # MVVM view models
    Views/                      # XAML views
tests/
  OptiGemini.Desktop.Tests/    # Unit and integration tests
```

## Architecture

### Services

- **MonitoringService**: Core monitoring orchestration with state machine
- **PowerShellBridge**: PowerShell script execution (hosted runspace or external process)
- **LoggingService**: Application logging with file persistence
- **ConfigurationService**: Configuration management (%APPDATA%/OptiGemini/config.json)
- **TrayIconService**: System tray icon and context menu

### State Machine

MonitoringService implements the following state transitions:

```
Idle → Starting → Running → Pausing → Paused
                   ↓                     ↓
                Stopping ← ← ← ← ← ← ← ←
                   ↓
                Stopped
```

### Feature Flags

**Engine.Runspace.Hosted** (config.json)
- `true`: Use embedded PowerShell runspace (default)
- `false`: Launch external pwsh.exe process (fallback mode)

## Configuration

Configuration file location: `%APPDATA%\OptiGemini\config.json`

Example configuration:

```json
{
  "Engine": {
    "Runspace": {
      "Hosted": true
    }
  },
  "Monitoring": {
    "PrimaryCheckAddress": "8.8.8.8",
    "SecondaryCheckAddress": "1.1.1.1",
    "TertiaryCheckAddress": "208.67.222.222",
    "CheckIntervalSeconds": 3,
    "MaxRetries": 5,
    "LatencyThreshold": 150
  },
  "Logging": {
    "LogLevel": "Information",
    "LogFilePath": ""
  }
}
```

## Story 1.2 Implementation Notes

This implementation delivers:

1. ✅ WPF MainWindow with Start/Stop/Pause/Resume buttons
2. ✅ MonitoringService with complete state machine
3. ✅ PowerShellBridge with feature flag support
4. ✅ System tray icon with synchronized context menu
5. ✅ LoggingService with real-time log viewer
6. ✅ Proper command enable/disable logic based on state
7. ✅ Toast notifications for tray actions
8. ✅ Unit tests for state transitions

## Next Steps

- Integrate actual PowerShell monitoring functions from OpTinternet.ps1
- Implement real-time metrics display in Dashboard tab
- Add Settings tab functionality
- Create PowerShell module (OptiGemini.psm1) for monitoring functions
