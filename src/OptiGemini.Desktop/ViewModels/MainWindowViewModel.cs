using OptiGemini.Desktop.Commands;
using OptiGemini.Desktop.Models;
using OptiGemini.Desktop.Services;
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Input;

namespace OptiGemini.Desktop.ViewModels;

/// <summary>
/// ViewModel for MainWindow with monitoring control commands
/// </summary>
public class MainWindowViewModel : ViewModelBase
{
    private readonly IMonitoringService _monitoringService;
    private readonly ILoggingService _loggingService;
    private readonly ITrayIconService _trayIconService;
    private MonitoringState _currentState;
    private string _statusText = "Idle";
    private string _statusColor = "#757575";

    public ObservableCollection<LogEntry> LogEntries { get; } = new();

    public MonitoringState CurrentState
    {
        get => _currentState;
        private set
        {
            if (SetProperty(ref _currentState, value))
            {
                UpdateStatusDisplay();
                UpdateCommandStates();
            }
        }
    }

    public string StatusText
    {
        get => _statusText;
        private set => SetProperty(ref _statusText, value);
    }

    public string StatusColor
    {
        get => _statusColor;
        private set => SetProperty(ref _statusColor, value);
    }

    // Commands
    public ICommand StartCommand { get; }
    public ICommand StopCommand { get; }
    public ICommand PauseCommand { get; }
    public ICommand ResumeCommand { get; }

    public MainWindowViewModel(
        IMonitoringService monitoringService,
        ILoggingService loggingService,
        ITrayIconService trayIconService)
    {
        _monitoringService = monitoringService;
        _loggingService = loggingService;
        _trayIconService = trayIconService;

        // Subscribe to service events
        _monitoringService.StateChanged += OnMonitoringStateChanged;
        _monitoringService.ErrorOccurred += OnMonitoringError;
        _loggingService.LogEntryAdded += OnLogEntryAdded;

        // Initialize commands
        StartCommand = new AsyncRelayCommand(
            execute: _ => ExecuteStartAsync(),
            canExecute: _ => CanExecuteStart());

        StopCommand = new AsyncRelayCommand(
            execute: _ => ExecuteStopAsync(),
            canExecute: _ => CanExecuteStop());

        PauseCommand = new AsyncRelayCommand(
            execute: _ => ExecutePauseAsync(),
            canExecute: _ => CanExecutePause());

        ResumeCommand = new AsyncRelayCommand(
            execute: _ => ExecuteResumeAsync(),
            canExecute: _ => CanExecuteResume());

        // Initialize state
        CurrentState = _monitoringService.CurrentState;
        
        // Initialize tray icon
        _trayIconService.Initialize();
        
        // Load recent log entries
        LoadRecentLogs();
    }

    private async Task ExecuteStartAsync()
    {
        try
        {
            _loggingService.LogInfo("User initiated monitoring start", "UI");
            await _monitoringService.StartAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to start monitoring: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private async Task ExecuteStopAsync()
    {
        try
        {
            _loggingService.LogInfo("User initiated monitoring stop", "UI");
            await _monitoringService.StopAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to stop monitoring: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private async Task ExecutePauseAsync()
    {
        try
        {
            _loggingService.LogInfo("User initiated monitoring pause", "UI");
            await _monitoringService.PauseAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to pause monitoring: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private async Task ExecuteResumeAsync()
    {
        try
        {
            _loggingService.LogInfo("User initiated monitoring resume", "UI");
            await _monitoringService.ResumeAsync();
            _trayIconService.ShowNotification("OptiGemini", "Monitoring resumed");
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to resume monitoring: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private bool CanExecuteStart() => 
        CurrentState == MonitoringState.Idle || CurrentState == MonitoringState.Stopped;

    private bool CanExecuteStop() => 
        CurrentState == MonitoringState.Running || 
        CurrentState == MonitoringState.Paused || 
        CurrentState == MonitoringState.Starting;

    private bool CanExecutePause() => 
        CurrentState == MonitoringState.Running;

    private bool CanExecuteResume() => 
        CurrentState == MonitoringState.Paused;

    private void OnMonitoringStateChanged(object? sender, StateChangedEventArgs e)
    {
        // Update on UI thread
        Application.Current.Dispatcher.Invoke(() =>
        {
            CurrentState = e.NewState;
            _trayIconService.UpdateTooltip($"OptiGemini - {GetStatusText(e.NewState)}");
        });
    }

    private void OnMonitoringError(object? sender, ErrorEventArgs e)
    {
        Application.Current.Dispatcher.Invoke(() =>
        {
            MessageBox.Show($"Monitoring error: {e.GetException()?.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        });
    }

    private void OnLogEntryAdded(object? sender, LogEntry e)
    {
        Application.Current.Dispatcher.Invoke(() =>
        {
            LogEntries.Add(e);
            
            // Keep only last 500 entries to prevent memory growth
            while (LogEntries.Count > 500)
            {
                LogEntries.RemoveAt(0);
            }
        });
    }

    private void LoadRecentLogs()
    {
        var recentEntries = _loggingService.GetRecentEntries(100);
        foreach (var entry in recentEntries)
        {
            LogEntries.Add(entry);
        }
    }

    private void UpdateStatusDisplay()
    {
        StatusText = GetStatusText(CurrentState);
        StatusColor = GetStatusColor(CurrentState);
    }

    private string GetStatusText(MonitoringState state) => state switch
    {
        MonitoringState.Idle => "Idle",
        MonitoringState.Starting => "Starting...",
        MonitoringState.Running => "Running",
        MonitoringState.Pausing => "Pausing...",
        MonitoringState.Paused => "Paused",
        MonitoringState.Stopping => "Stopping...",
        MonitoringState.Stopped => "Stopped",
        _ => "Unknown"
    };

    private string GetStatusColor(MonitoringState state) => state switch
    {
        MonitoringState.Running => "#4CAF50",      // Success/Green
        MonitoringState.Paused => "#FF9800",       // Warning/Orange
        MonitoringState.Starting => "#1E88E5",     // Primary/Blue
        MonitoringState.Stopping => "#1E88E5",     // Primary/Blue
        MonitoringState.Pausing => "#FF9800",      // Warning/Orange
        MonitoringState.Stopped => "#F44336",      // Error/Red
        _ => "#757575"                             // Text secondary/Gray
    };

    private void UpdateCommandStates()
    {
        // Force re-evaluation of CanExecute for all commands
        if (StartCommand is AsyncRelayCommand startCmd) startCmd.RaiseCanExecuteChanged();
        if (StopCommand is AsyncRelayCommand stopCmd) stopCmd.RaiseCanExecuteChanged();
        if (PauseCommand is AsyncRelayCommand pauseCmd) pauseCmd.RaiseCanExecuteChanged();
        if (ResumeCommand is AsyncRelayCommand resumeCmd) resumeCmd.RaiseCanExecuteChanged();
    }
}
