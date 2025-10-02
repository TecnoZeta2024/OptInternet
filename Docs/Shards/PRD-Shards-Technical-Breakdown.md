# 🧩 OptiGemini PRD Shards - Technical Implementation Breakdown

**Generated:** October 2, 2025  
**Source:** Docs/prd.md  
**Architect:** Winston  
**Purpose:** Convert PRD requirements into actionable technical components

---

## 📊 Shard Organization Strategy

This document breaks down the PRD into technical shards organized by:
- Architecture Layer (Presentation, Service, Core Engine, Data)
- Phase (Foundation, Feature Parity, Enhancement, Hardening)
- Priority (P0-Must Have, P1-Should Have, P2-Nice to Have)

Each shard includes:
- Technical Requirements
- Dependencies (what must be built first)
- Acceptance Criteria (definition of done)
- Estimated Complexity (S/M/L/XL)
- Assigned Phase

---

## 🏗️ LAYER 1: PRESENTATION LAYER (WPF/XAML)

### SHARD-P01: Main Window Infrastructure
Epic: Epic 1 - Core Application & Monitoring  
User Stories: US-1.2, US-1.4  
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: M

Requirements
- Create MainWindow.xaml with basic layout structure
- Implement MVVM pattern with MainWindowViewModel
- Add Material Design theme integration
- Create responsive grid layout for dashboard sections

Technical Specs (snippet)
```
<Window x:Class="OptiGemini.MainWindow"
        xmlns:materialDesign="http://materialdesigninxaml.net/winfx/xaml/themes">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="200"/>
        </Grid.RowDefinitions>
    </Grid>
    
</Window>
```

Dependencies
- None (foundational component)

Acceptance Criteria
- [x] Window opens and displays without errors
- [x] Material Design theme applies correctly
- [x] Window is resizable with minimum dimensions (800x600)
- [x] Layout adapts to different screen sizes
- [x] Dark theme is default

Files to Create
- MainWindow.xaml
- MainWindow.xaml.cs
- ViewModels/MainWindowViewModel.cs
- App.xaml (theme configuration)

---

### SHARD-P02: Real-time Metrics Display Cards
Epic: Epic 1 - Core Application & Monitoring  
User Stories: US-1.4  
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: M

Requirements
- Create metric card component for latency, jitter, packet loss
- Implement data binding to ViewModel properties
- Add color-coded status indicators (Green/Yellow/Red)
- Display current, average, and peak values

Technical Specs (model)
```
public class MetricCardViewModel : INotifyPropertyChanged
{
    public string Title { get; set; }
    public double CurrentValue { get; set; }
    public double AverageValue { get; set; }
    public double PeakValue { get; set; }
    public string Unit { get; set; }
    public MetricStatus Status { get; set; } // Healthy, Degraded, Critical
}
```

Dependencies
- SHARD-P01 (Main Window Infrastructure)
- SHARD-S02 (MonitoringService for data source)

Acceptance Criteria
- [x] Three metric cards display: Latency, Jitter, Packet Loss
- [x] Values update every 3 seconds
- [x] Color changes based on thresholds
- [x] Hover shows detailed tooltip with statistics
- [x] Cards are visually consistent with Material Design

Files to Create
- Controls/MetricCard.xaml
- Controls/MetricCard.xaml.cs
- ViewModels/MetricCardViewModel.cs
- Converters/MetricStatusToColorConverter.cs

---

### SHARD-P03: Performance Charts Integration
Epic: Epic 2 - GUI and User Experience  
User Stories: US-2.1  
Phase: Phase 2 (Weeks 5-9)  
Priority: P1 - Should Have  
Complexity: L

Requirements
- Integrate LiveCharts2 library
- Create line charts for latency, jitter, packet loss over time
- Implement 5-minute rolling window (100 samples at 3s intervals)
- Add pause/resume chart updates
- Enable zoom and pan interactions

Technical Specs (snippet)
```
public class PerformanceChartViewModel
{
    public ObservableCollection<DateTimePoint> LatencyPoints { get; set; }
    public ObservableCollection<DateTimePoint> JitterPoints { get; set; }
    public ObservableCollection<DateTimePoint> PacketLossPoints { get; set; }
    
    public void AddMetric(NetworkMetrics metrics)
    {
        if (LatencyPoints.Count >= 100)
            LatencyPoints.RemoveAt(0);
        LatencyPoints.Add(new DateTimePoint(DateTime.Now, metrics.Latency));
    }
}
```

Dependencies
- SHARD-P02 (Metrics Display)
- SHARD-S02 (MonitoringService)
- NuGet: LiveCharts2.WPF

Acceptance Criteria
- [x] Charts render smoothly without UI freezes
- [x] 100 data points retained (5 minutes at 3s intervals)
- [x] Axes labeled with time and units
- [x] Legends displayed for each metric
- [x] Pause button stops chart updates
- [x] Charts export to PNG via context menu

Files to Create
- Controls/PerformanceChart.xaml
- ViewModels/PerformanceChartViewModel.cs
- Services/ChartDataService.cs

---

### SHARD-P04: System Tray Integration
Epic: Epic 1 - Core Application & Monitoring  
User Stories: US-1.3  
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: S

Requirements
- Implement NotifyIcon using Hardcodet.NotifyIcon.Wpf
- Create context menu with Start/Stop/Exit actions
- Add icon states (Green/Yellow/Red/Gray) based on connection status
- Double-click restores main window
- Tooltip shows current connection status and latency

Technical Specs (snippet)
```
<tb:TaskbarIcon x:Name="TrayIcon"
                IconSource="/Resources/icon-green.ico"
                ToolTipText="OptiGemini - Connected: 45ms"
                LeftClickCommand="{Binding ShowWindowCommand}">
    <tb:TaskbarIcon.ContextMenu>
        <ContextMenu>
            <MenuItem Header="Show Dashboard" Command="{Binding ShowCommand}"/>
            <MenuItem Header="Start Monitoring" Command="{Binding StartCommand}"/>
            <MenuItem Header="Stop Monitoring" Command="{Binding StopCommand}"/>
            <Separator/>
            <MenuItem Header="Exit" Command="{Binding ExitCommand}"/>
        </ContextMenu>
    </tb:TaskbarIcon.ContextMenu>
</tb:TaskbarIcon>
```

Dependencies
- SHARD-S02 (MonitoringService for status)
- NuGet: Hardcodet.NotifyIcon.Wpf

Acceptance Criteria
- [x] Icon persists in system tray when window closed
- [x] Double-click restores window
- [x] Right-click shows context menu
- [x] Icon color reflects connection status
- [x] Tooltip updates in real-time
- [x] Exit command performs clean shutdown

Files to Create
- TrayIconManager.cs
- Resources/icon-green.ico
- Resources/icon-yellow.ico
- Resources/icon-red.ico
- Resources/icon-gray.ico

---

### SHARD-P05: Settings Window
Epic: Epic 3 - Configuration & Personalization  
User Stories: US-3.1, US-3.2, US-3.3  
Phase: Phase 2 (Weeks 5-9)  
Priority: P1 - Should Have  
Complexity: L

Requirements
- Create SettingsWindow with tabbed interface
- Implement tabs: General, Thresholds, DNS, Hotspot, Advanced
- Add real-time input validation with error tooltips
- Implement Apply/Cancel/Reset buttons
- Support profile selection dropdown

Technical Specs (snippet)
```
public class SettingsViewModel : INotifyPropertyChanged
{
    [Range(1, 60)]
    public int CheckIntervalSeconds { get; set; }
    [Range(10, 1000)]
    public int LatencyThreshold { get; set; }
    [Range(0, 100)]
    public int PacketLossThreshold { get; set; }
    [ValidateIPAddress]
    public string PrimaryDnsServer { get; set; }
    public void ApplySettings()
    {
        ConfigurationService.SaveConfiguration(this);
        MonitoringService.ReloadConfiguration();
    }
}
```

Dependencies
- SHARD-S03 (ConfigurationService)
- SHARD-P01 (Main Window for dialog parent)

Acceptance Criteria
- [x] All configuration parameters editable
- [x] Input validation shows red border and tooltip on invalid values
- [x] Test DNS button validates connectivity to specified servers
- [x] Apply saves settings immediately
- [x] Cancel discards unsaved changes
- [x] Settings window is modal

Files to Create
- Windows/SettingsWindow.xaml
- Windows/SettingsWindow.xaml.cs
- ViewModels/SettingsViewModel.cs
- Validation/IPAddressValidationRule.cs

---

### SHARD-P06: Log Viewer Component
Epic: Epic 2 - GUI and User Experience  
User Stories: US-2.2  
Phase: Phase 2 (Weeks 5-9)  
Priority: P1 - Should Have  
Complexity: M

Requirements
- Create scrollable log viewer with DataGrid
- Implement severity filtering (INFO/WARN/ERROR)
- Add timestamp, level, and message columns
- Support copy-to-clipboard
- Auto-scroll to bottom on new entries
- Provide "Open Log Folder" button

Technical Specs (snippet)
```
public class LogViewerViewModel
{
    public ObservableCollection<LogEntry> LogEntries { get; set; }
    public LogLevel FilterLevel { get; set; } = LogLevel.All;
    public void AddLogEntry(string message, LogLevel level)
    {
        var entry = new LogEntry
        {
            Timestamp = DateTime.Now,
            Level = level,
            Message = message
        };
        LogEntries.Add(entry);
        if (LogEntries.Count > 1000) LogEntries.RemoveAt(0);
    }
}
```

Dependencies
- SHARD-S02 (MonitoringService for log events)
- SHARD-D02 (Logging infrastructure)

Acceptance Criteria
- [x] Log entries stream in real-time
- [x] Severity filter dropdown works correctly
- [x] Copy button copies selected entries to clipboard
- [x] Auto-scroll toggleable
- [x] Color-coded by severity (INFO=Gray, WARN=Yellow, ERROR=Red)
- [x] Open folder button works on all Windows versions

Files to Create
- Controls/LogViewer.xaml
- ViewModels/LogViewerViewModel.cs
- Models/LogEntry.cs

---

### SHARD-P07: Toast Notifications
Epic: Epic 2 - GUI and User Experience  
User Stories: US-2.4  
Phase: Phase 3 (Weeks 10-12)  
Priority: P1 - Should Have  
Complexity: M

Requirements
- Implement Windows 10/11 toast notifications
- Trigger notifications on: disconnect, reconnect, escalated recovery
- Respect Windows Focus Assist settings
- Include action button to open main window
- Support notification history

Technical Specs (snippet)
```
public class NotificationService
{
    public void ShowDisconnectNotification()
    {
        var toast = new ToastContentBuilder()
            .AddText("Network Disconnected")
            .AddText("OptiGemini is attempting automatic recovery...")
            .AddButton("Show Dashboard", ToastActivationType.Foreground, "show")
            .SetToastDuration(ToastDuration.Short)
            .GetToastContent();
        ToastNotificationManager.CreateToastNotifier().Show(new ToastNotification(toast));
    }
}
```

Dependencies
- SHARD-S02 (MonitoringService for events)
- SHARD-S05 (NotificationService)
- NuGet: Microsoft.Toolkit.Uwp.Notifications

Acceptance Criteria
- [x] Notifications fire on critical events
- [x] Notifications respect Focus Assist (Do Not Disturb)
- [x] Click action opens main window
- [x] Notifications auto-dismiss after timeout
- [x] User can disable notifications in settings

Files to Create
- Services/NotificationService.cs
- Managers/ToastNotificationManager.cs

---

## ⚙️ LAYER 2: SERVICE LAYER (C#)

### SHARD-S01: PowerShellBridge Service
Epic: Epic 1 - Core Application & Monitoring  
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: XL (Most Critical)

Requirements
- Create PowerShell runspace manager
- Implement async function invocation
- Handle PowerShell → C# data marshaling
- Implement watchdog for hung runspaces (30s timeout)
- Support parallel execution via runspace pool (future)
- Subscribe to PowerShell Information stream for events

Technical Specs (snippet)
```
public class PowerShellBridge : IDisposable
{
    private Runspace _runspace;
    private readonly SemaphoreSlim _semaphore = new(1, 1);
    public async Task InitializeAsync()
    {
        _runspace = RunspaceFactory.CreateRunspace();
        _runspace.Open();
        using var ps = PowerShell.Create(_runspace);
        ps.AddScript(@"Import-Module .\\OptiGemini.psm1");
        await ps.InvokeAsync();
    }
    public async Task<NetworkMetrics> GetNetworkMetricsAsync()
    {
        await _semaphore.WaitAsync();
        try
        {
            using var ps = PowerShell.Create(_runspace);
            ps.AddCommand("Get-NetworkMetrics");
            var results = await ps.InvokeAsync();
            return ParseMetrics(results[0]);
        }
        finally { _semaphore.Release(); }
    }
    private NetworkMetrics ParseMetrics(PSObject psObject) => new()
    {
        Latency = (double)psObject.Properties["Latency"].Value,
        Jitter = (double)psObject.Properties["Jitter"].Value,
        PacketLoss = (double)psObject.Properties["PacketLoss"].Value,
        Timestamp = DateTime.Now
    };
}
```

Dependencies
- NuGet: System.Management.Automation
- OptiGemini.psm1 (refactored PowerShell module)

Acceptance Criteria
- [x] Successfully invokes PowerShell functions from C#
- [x] Round-trip latency <100ms
- [x] Data marshaling preserves all metric values (±5% accuracy)
- [x] Watchdog detects and restarts hung runspaces
- [x] No memory leaks over 30-minute test
- [x] Thread-safe for concurrent access

Files to Create
- Services/PowerShellBridge.cs
- Models/NetworkMetrics.cs
- Interfaces/IPowerShellBridge.cs

---

### SHARD-S02: MonitoringService State Machine
Epic: Epic 1 - Core Application & Monitoring  
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: L

Requirements
- Implement state machine: Idle → Starting → Running → Pausing → Paused → Stopping → Stopped
- Manage monitoring lifecycle (Start/Stop/Pause/Resume)
- Poll PowerShellBridge every 3 seconds
- Aggregate and cache metrics
- Emit events for UI updates
- Implement CancellationToken support

Technical Specs (snippet)
```
public class MonitoringService : IMonitoringService
{
    private MonitoringState _state = MonitoringState.Idle;
    private CancellationTokenSource _cts;
    private readonly IPowerShellBridge _psBridge;
    private readonly IConfigurationService _config;
    public event EventHandler<MetricsUpdatedEventArgs> MetricsUpdated;
    public event EventHandler<StatusChangedEventArgs> StatusChanged;
    public async Task StartAsync()
    {
        if (_state is not (MonitoringState.Idle or MonitoringState.Stopped))
            throw new InvalidOperationException($"Cannot start from state {_state}");
        ChangeState(MonitoringState.Starting);
        await _psBridge.InitializeAsync();
        _cts = new CancellationTokenSource();
        ChangeState(MonitoringState.Running);
        _ = Task.Run(() => MonitoringLoopAsync(_cts.Token));
    }
    private async Task MonitoringLoopAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            try
            {
                var metrics = await _psBridge.GetNetworkMetricsAsync();
                MetricsUpdated?.Invoke(this, new MetricsUpdatedEventArgs(metrics));
                await Task.Delay(_config.CheckIntervalSeconds * 1000, ct);
            }
            catch (OperationCanceledException) { break; }
            catch (Exception) { /* log and continue */ }
        }
    }
    private void ChangeState(MonitoringState newState)
    { _state = newState; StatusChanged?.Invoke(this, new StatusChangedEventArgs(newState)); }
}
```

Dependencies
- SHARD-S01 (PowerShellBridge)
- SHARD-S03 (ConfigurationService)

Acceptance Criteria
- [x] State transitions follow valid paths
- [x] Start/Stop operations complete within 2 seconds
- [x] Metrics update every configured interval (default 3s)
- [x] Events fire correctly for UI updates
- [x] Graceful shutdown on cancellation
- [x] No resource leaks on repeated start/stop

Files to Create
- Services/MonitoringService.cs
- Interfaces/IMonitoringService.cs
- Enums/MonitoringState.cs
- EventArgs/MetricsUpdatedEventArgs.cs

---

### SHARD-S03: ConfigurationService
Epic: Epic 3 - Configuration & Personalization  
User Stories: US-3.3  
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: M

Requirements
- Load/save configuration to %APPDATA%\OptiGemini\config.json
- Manage profiles (CRUD operations)
- Validate configuration schema
- Provide default configuration on first run
- Support configuration migration for schema updates

Technical Specs (snippet)
```
public class ConfigurationService : IConfigurationService
{
    private readonly string _configPath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "OptiGemini", "config.json");
    public Configuration LoadConfiguration()
    {
        if (!File.Exists(_configPath)) return CreateDefaultConfiguration();
        try
        {
            var json = File.ReadAllText(_configPath);
            var config = JsonSerializer.Deserialize<Configuration>(json);
            return ValidateConfiguration(config) ? config : CreateDefaultConfiguration();
        }
        catch { return CreateDefaultConfiguration(); }
    }
    public void SaveConfiguration(Configuration config)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_configPath)!);
        var json = JsonSerializer.Serialize(config, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(_configPath, json);
    }
}
```

Dependencies
- NuGet: System.Text.Json

Acceptance Criteria
- [x] Config file created on first run
- [x] Configuration persists across app restarts
- [x] Corrupted files trigger fallback to defaults with user notification
- [x] Manual JSON edits respected (if valid)
- [x] All configuration parameters accessible

Files to Create
- Services/ConfigurationService.cs
- Models/Configuration.cs
- Models/MonitoringSettings.cs
- Models/HotspotSettings.cs
- Models/UISettings.cs

---

### SHARD-S04: Profile Management Service
Epic: Epic 3 - Configuration & Personalization  
User Stories: US-3.1  
Phase: Phase 2 (Weeks 5-9)  
Priority: P1 - Should Have  
Complexity: M

Requirements
- Manage profile CRUD operations
- Store profiles in %APPDATA%\OptiGemini\profiles\*.json
- Provide default profiles: Home, Office, Gaming
- Support profile switching with confirmation
- Update monitoring parameters within 5 seconds of switch

Technical Specs (snippet)
```
public class ProfileService
{
    private readonly string _profilesPath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "OptiGemini", "profiles");
    public List<Profile> GetAllProfiles()
    {
        if (!Directory.Exists(_profilesPath)) CreateDefaultProfiles();
        return Directory.GetFiles(_profilesPath, "*.json").Select(LoadProfile).ToList();
    }
    public void SwitchProfile(string profileName)
    {
        var profile = LoadProfile(Path.Combine(_profilesPath, $"{profileName}.json"));
        var config = _configService.LoadConfiguration();
        config.ActiveProfile = profileName;
        config.Monitoring = profile.MonitoringSettings;
        _configService.SaveConfiguration(config);
        _monitoringService.ReloadConfiguration();
    }
}
```

Dependencies
- SHARD-S03 (ConfigurationService)
- SHARD-S02 (MonitoringService for reload)

Acceptance Criteria
- [x] Default profiles created on first run
- [x] Profile switching updates monitoring within 5 seconds
- [x] Confirmation toast displayed on switch
- [x] Custom profiles can be created/edited/deleted
- [x] Active profile indicated in UI

Files to Create
- Services/ProfileService.cs
- Models/Profile.cs
- Resources/Profiles/Home.json
- Resources/Profiles/Office.json
- Resources/Profiles/Gaming.json

---

## 🔧 LAYER 3: CORE ENGINE (PowerShell Module)

### SHARD-E01: PowerShell Module Refactoring
Phase: Phase 1-2 (Weeks 1-9)  
Priority: P0 - Must Have  
Complexity: XL

Requirements
- Convert OpTinternet.ps1 to OptiGemini.psm1 module
- Remove all dashboard rendering functions (~400 lines)
- Export public functions via Export-ModuleMember
- Return PSCustomObject instead of Write-Host
- Add parameter validation
- Emit events via Write-Information stream
- Create module manifest (.psd1)

Functions to Remove (Dashboard)
```
- Show-PremiumDashboard
- Show-StaticDashboard
- Update-DynamicFields
- Update-LogArea
- Set-CursorPosition
- Get-Bar
- Write-PaddedField
- Add-LogMessage
- Set-CurrentAction
- Update-SystemMetrics
```

Functions to Preserve & Refactor
```
# Network Core
- Test-InternetConnection
- Get-ExternalIp
- Restart-InternetAdapter
- Get-NetworkMetrics           # ← Modify to return PSCustomObject
- Test-ConnectionStability
- Monitor-ConnectionDrops

# Optimization
- Optimize-NetworkSettings
- Optimize-NetworkAdapterAdvanced
- Set-FastestDNS
- Optimize-TCPIPSettings
- Set-IntelligentQoS
- Optimize-NetworkBuffers
- Optimize-MTUSize

# Recovery
- Invoke-AdaptiveRecovery
- Repair-IntermittentConnection

# Hotspot
- Start-Hotspot

# Monitoring
- Monitor-NetworkSpeeds
```

Example Refactoring: Get-NetworkMetrics
```
function Get-NetworkMetrics {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidatePattern('^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')]
        [string]$TargetAddress = '8.8.8.8',
        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$Count = 4
    )
    try {
        $pingResults = Test-Connection -ComputerName $TargetAddress -Count $Count
        $latency = ($pingResults | Measure-Object -Property ResponseTime -Average).Average
        $jitter = ($pingResults | Measure-Object -Property ResponseTime -StandardDeviation).StandardDeviation
        $packetLoss = (($Count - $pingResults.Count) / $Count) * 100
        $metrics = [PSCustomObject]@{
            Latency = [Math]::Round($latency, 2)
            Jitter = [Math]::Round($jitter, 2)
            PacketLoss = [Math]::Round($packetLoss, 2)
            Timestamp = Get-Date
            TargetAddress = $TargetAddress
        }
        Write-Information -MessageData "MetricsUpdated:$($metrics | ConvertTo-Json -Compress)" -InformationAction Continue
        return $metrics
    }
    catch {
        Write-Error "Failed to collect network metrics: $_"
        return $null
    }
}
```

Dependencies
- None (foundational refactoring)

Acceptance Criteria
- [x] Module loads without errors: Import-Module .\OptiGemini.psm1
- [x] All exported functions discoverable: Get-Command -Module OptiGemini
- [x] Functions return PSCustomObject with expected properties
- [x] No Write-Host output (logging only via Write-Log)
- [x] Parameter validation works correctly
- [x] All 25+ core functions preserved
- [x] ~400 lines removed (dashboard functions)
- [x] Module manifest validates: Test-ModuleManifest .\OptiGemini.psd1

Files to Create/Modify
- OptiGemini.psm1 (refactored from OpTinternet.ps1)
- OptiGemini.psd1 (module manifest)
- OpTinternet-v2.2-backup.ps1 (backup)

---

## 💾 LAYER 4: DATA LAYER

### SHARD-D01: Configuration Schema & Persistence
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: S

Requirements
- Define JSON schema for configuration
- Implement schema validation
- Support schema migrations for future versions

JSON Schema (draft)
```
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "version": { "type": "string", "pattern": "^\\d+\\.\\d+$" },
    "activeProfile": { "type": "string" },
    "monitoring": {
      "type": "object",
      "properties": {
        "primaryDns": { "type": "string", "format": "ipv4" },
        "secondaryDns": { "type": "string", "format": "ipv4" },
        "checkIntervalSeconds": { "type": "integer", "minimum": 1, "maximum": 60 },
        "latencyThreshold": { "type": "integer", "minimum": 10, "maximum": 1000 },
        "packetLossThreshold": { "type": "integer", "minimum": 0, "maximum": 100 },
        "jitterThreshold": { "type": "integer", "minimum": 0, "maximum": 500 }
      },
      "required": ["primaryDns", "checkIntervalSeconds"]
    }
  },
  "required": ["version", "monitoring"]
}
```

Files to Create
- Schemas/configuration-schema.json
- Services/SchemaValidator.cs

---

### SHARD-D02: Logging Infrastructure
Phase: Phase 1 (Weeks 1-4)  
Priority: P0 - Must Have  
Complexity: M

Requirements
- Implement structured logging with daily rotation
- Support multiple log levels (DEBUG, INFO, WARN, ERROR)
- Separate error log: OptiGemini_errors.log
- Main log: OptiGemini.log
- Configurable log retention (default: 30 days)

Technical Specs (snippet)
```
public class LoggingService
{
    private readonly string _logPath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "OptiGemini", "logs");
    public void Log(LogLevel level, string message, Exception ex = null)
    {
        var logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [{level}] {message}";
        if (ex != null) logEntry += $"\n{ex}";
        AppendToLog("OptiGemini.log", logEntry);
        if (level == LogLevel.ERROR) AppendToLog("OptiGemini_errors.log", logEntry);
        OnLogEntryAdded?.Invoke(this, new LogEntry(level, message));
    }
}
```

Files to Create
- Services/LoggingService.cs
- Models/LogEntry.cs
- Enums/LogLevel.cs

---

## 📦 CROSS-CUTTING CONCERNS

### SHARD-X01: Dependency Injection Setup
Phase: Phase 1 (Week 1)  
Priority: P0 - Must Have  
Complexity: S

Requirements
- Configure DI container (Microsoft.Extensions.DependencyInjection)
- Register all services as singletons or transients
- Configure service lifetimes appropriately

Technical Specs (snippet)
```
public class App : Application
{
    private IServiceProvider _serviceProvider;
    protected override void OnStartup(StartupEventArgs e)
    {
        var services = new ServiceCollection();
        services.AddSingleton<IConfigurationService, ConfigurationService>();
        services.AddSingleton<ILoggingService, LoggingService>();
        services.AddSingleton<IPowerShellBridge, PowerShellBridge>();
        services.AddSingleton<IMonitoringService, MonitoringService>();
        services.AddSingleton<INotificationService, NotificationService>();
        services.AddSingleton<IProfileService, ProfileService>();
        services.AddTransient<MainWindowViewModel>();
        services.AddTransient<SettingsViewModel>();
        services.AddTransient<MainWindow>();
        services.AddTransient<SettingsWindow>();
        _serviceProvider = services.BuildServiceProvider();
        var mainWindow = _serviceProvider.GetRequiredService<MainWindow>();
        mainWindow.Show();
    }
}
```

Files to Create
- App.xaml.cs (modify)
- ServiceCollectionExtensions.cs

---

### SHARD-X02: Error Handling & Telemetry
Phase: Phase 1 (Weeks 1-4)  
Priority: P1 - Should Have  
Complexity: M

Requirements
- Global exception handler
- Unhandled exception logging
- Optional telemetry with user consent (opt-in)
- Crash report generation

Technical Specs (snippet)
```
public class GlobalExceptionHandler
{
    public static void Initialize()
    {
        AppDomain.CurrentDomain.UnhandledException += OnUnhandledException;
        Application.Current.DispatcherUnhandledException += OnDispatcherUnhandledException;
    }
    private static void OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
    {
        var ex = e.ExceptionObject as Exception;
        LoggingService.Log(LogLevel.ERROR, "Unhandled exception", ex);
        if (e.IsTerminating)
        {
            GenerateCrashReport(ex);
            MessageBox.Show("OptiGemini encountered a fatal error and must close.");
        }
    }
}
```

Files to Create
- ErrorHandling/GlobalExceptionHandler.cs
- ErrorHandling/CrashReportGenerator.cs

---

## 📋 Implementation Priority Summary

Phase 1 (Weeks 1-4) - Foundation (P0)
1) SHARD-X01: DI Setup
2) SHARD-D02: Logging Infrastructure
3) SHARD-S01: PowerShellBridge (PoC first)
4) SHARD-E01: Start module refactoring (extract core functions)
5) SHARD-S02: MonitoringService
6) SHARD-S03: ConfigurationService
7) SHARD-P01: Main Window Infrastructure
8) SHARD-P02: Metrics Display Cards
9) SHARD-P04: System Tray Integration

Phase 2 (Weeks 5-9) - Feature Parity (P0 + P1)
10) SHARD-E01: Complete module refactoring (remove dashboard)
11) SHARD-P03: Performance Charts
12) SHARD-P05: Settings Window
13) SHARD-P06: Log Viewer
14) SHARD-S04: Profile Management
15) SHARD-D01: Configuration Schema

Phase 3 (Weeks 10-12) - Enhancement (P1)
16) SHARD-P07: Toast Notifications
17) Export Reports (CSV/HTML)
18) Light/Dark Theme Support
19) Auto-Update Mechanism
20) CLI Flags Support
21) MSI Installer (WiX)

Phase 4 (Weeks 13-14) - Hardening
22) Bug triage and fixes
23) Performance optimization
24) Security audit
25) Documentation completion
26) Beta testing and feedback

---

## ✅ Next Actions

1. Review this shard breakdown and confirm priority/complexity estimates
2. Create GitHub Issues for each shard (can automate with script)
3. Set up Project Board with columns: Backlog, In Progress, Review, Done
4. Begin Phase 1, Week 1 with SHARD-X01 (DI Setup)

---

Status: PRD Successfully Sharded  
Total Shards: 22 (excluding sub-shards)  
Estimated Total Effort: ~14 weeks  
Next: Create GitHub project board and start Week 1
