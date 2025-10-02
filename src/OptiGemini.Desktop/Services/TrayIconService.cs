using Hardcodet.Wpf.TaskbarNotification;
using Microsoft.Extensions.Logging;
using OptiGemini.Desktop.Models;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// System tray icon service with state-driven icons and real-time status updates
/// </summary>
public class TrayIconService : ITrayIconService, IDisposable
{
    private readonly ILogger<TrayIconService> _logger;
    private readonly IMonitoringService _monitoringService;
    private readonly ILoggingService _loggingService;
    private readonly IConfigurationService _configService;
    private TaskbarIcon? _taskbarIcon;
    private bool _disposed;
    private DispatcherTimer? _updateTimer;
    private ConnectionStatus _lastStatus = ConnectionStatus.Offline;

    public TrayIconService(
        ILogger<TrayIconService> logger,
        IMonitoringService monitoringService,
        ILoggingService loggingService,
        IConfigurationService configService)
    {
        _logger = logger;
        _monitoringService = monitoringService;
        _loggingService = loggingService;
        _configService = configService;
    }

    public void Initialize()
    {
        try
        {
            _taskbarIcon = new TaskbarIcon
            {
                ToolTipText = "OptiGemini - Initializing...",
                IconSource = GetIconForStatus(ConnectionStatus.Offline),
                ContextMenu = CreateContextMenu()
            };

            // Double-click handler to restore main window
            _taskbarIcon.TrayLeftMouseDown += OnTrayDoubleClick;

            // Subscribe to monitoring state changes
            _monitoringService.StateChanged += OnMonitoringStateChanged;

            // Start update timer for tooltip refresh at 3-second intervals
            _updateTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(3)
            };
            _updateTimer.Tick += OnUpdateTimerTick;
            _updateTimer.Start();

            _logger.LogInformation("Tray icon initialized with state monitoring");
            _loggingService.LogInfo("System tray icon initialized", "TrayIcon");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initialize tray icon");
            _loggingService.LogError($"Tray icon initialization failed: {ex.Message}", "TrayIcon");
        }
    }

    public void ShowNotification(string title, string message)
    {
        try
        {
            _taskbarIcon?.ShowBalloonTip(title, message, BalloonIcon.Info);
            _logger.LogDebug("Showed notification: {Title} - {Message}", title, message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to show notification");
        }
    }

    public void UpdateTooltip(string tooltip)
    {
        try
        {
            if (_taskbarIcon != null)
            {
                _taskbarIcon.ToolTipText = tooltip;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to update tooltip");
        }
    }

    private void OnTrayDoubleClick(object? sender, RoutedEventArgs e)
    {
        try
        {
            var mainWindow = Application.Current.MainWindow;
            if (mainWindow != null)
            {
                mainWindow.Show();
                mainWindow.WindowState = WindowState.Normal;
                mainWindow.Activate();
                _logger.LogInformation("Main window restored from tray");
                _loggingService.LogInfo("Dashboard window restored from tray", "TrayIcon");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to restore main window from tray");
        }
    }

    private void OnMonitoringStateChanged(object? sender, StateChangedEventArgs e)
    {
        try
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                UpdateStatusDisplay(e.NewState);
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to handle state change");
        }
    }

    private void OnUpdateTimerTick(object? sender, EventArgs e)
    {
        try
        {
            UpdateStatusDisplay(_monitoringService.CurrentState);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to update tray status");
        }
    }

    private void UpdateStatusDisplay(MonitoringState state)
    {
        var status = DetermineConnectionStatus(state);
        
        if (status != _lastStatus)
        {
            _lastStatus = status;
            if (_taskbarIcon != null)
            {
                _taskbarIcon.IconSource = GetIconForStatus(status);
            }
        }

        // Update tooltip with current status
        var tooltipText = state switch
        {
            MonitoringState.Idle => "OptiGemini - Idle",
            MonitoringState.Starting => "OptiGemini - Starting...",
            MonitoringState.Running => $"OptiGemini - {GetStatusText(status)}",
            MonitoringState.Paused => "OptiGemini - Paused",
            MonitoringState.Stopping => "OptiGemini - Stopping...",
            MonitoringState.Stopped => "OptiGemini - Stopped",
            _ => "OptiGemini"
        };

        UpdateTooltip(tooltipText);
    }

    private ConnectionStatus DetermineConnectionStatus(MonitoringState state)
    {
        // In a real implementation, this would query actual network metrics
        // For now, we derive from monitoring state
        return state switch
        {
            MonitoringState.Running => ConnectionStatus.Optimal,
            MonitoringState.Starting => ConnectionStatus.Degraded,
            MonitoringState.Paused => ConnectionStatus.Degraded,
            _ => ConnectionStatus.Offline
        };
    }

    private string GetStatusText(ConnectionStatus status)
    {
        return status switch
        {
            ConnectionStatus.Optimal => "Optimal Connection",
            ConnectionStatus.Degraded => "Degraded Connection",
            ConnectionStatus.Offline => "Offline",
            _ => "Unknown"
        };
    }

    private System.Windows.Media.ImageSource GetIconForStatus(ConnectionStatus status)
    {
        // Create status-specific icons with appropriate colors
        var color = status switch
        {
            ConnectionStatus.Optimal => System.Windows.Media.Color.FromRgb(76, 175, 80),    // Green
            ConnectionStatus.Degraded => System.Windows.Media.Color.FromRgb(255, 193, 7),   // Amber
            ConnectionStatus.Offline => System.Windows.Media.Color.FromRgb(244, 67, 54),    // Red
            _ => System.Windows.Media.Color.FromRgb(158, 158, 158)                          // Gray
        };

        var drawingGroup = new System.Windows.Media.DrawingGroup();
        
        // Create circle with status color
        var geometryDrawing = new System.Windows.Media.GeometryDrawing
        {
            Brush = new System.Windows.Media.SolidColorBrush(color),
            Pen = new System.Windows.Media.Pen(new System.Windows.Media.SolidColorBrush(
                System.Windows.Media.Color.FromRgb(255, 255, 255)), 1),
            Geometry = new System.Windows.Media.EllipseGeometry(new System.Windows.Point(8, 8), 7, 7)
        };
        drawingGroup.Children.Add(geometryDrawing);

        var drawingImage = new System.Windows.Media.DrawingImage(drawingGroup);
        return drawingImage;
    }

    private ContextMenu CreateContextMenu()
    {
        var contextMenu = new ContextMenu();

        // Start menu item
        var startItem = new MenuItem { Header = "▶ Start" };
        startItem.Click += async (s, e) =>
        {
            try
            {
                _loggingService.LogInfo("Start requested from tray menu", "TrayIcon");
                await _monitoringService.StartAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to start from tray");
                MessageBox.Show($"Failed to start: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        };
        contextMenu.Items.Add(startItem);

        // Pause menu item
        var pauseItem = new MenuItem { Header = "⏸ Pause" };
        pauseItem.Click += async (s, e) =>
        {
            try
            {
                _loggingService.LogInfo("Pause requested from tray menu", "TrayIcon");
                await _monitoringService.PauseAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to pause from tray");
            }
        };
        contextMenu.Items.Add(pauseItem);

        // Resume menu item
        var resumeItem = new MenuItem { Header = "▶ Resume" };
        resumeItem.Click += async (s, e) =>
        {
            try
            {
                _loggingService.LogInfo("Resume requested from tray menu", "TrayIcon");
                await _monitoringService.ResumeAsync();
                ShowNotification("OptiGemini", "Monitoring resumed from tray");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to resume from tray");
            }
        };
        contextMenu.Items.Add(resumeItem);

        // Stop menu item
        var stopItem = new MenuItem { Header = "⏹ Stop" };
        stopItem.Click += async (s, e) =>
        {
            try
            {
                _loggingService.LogInfo("Stop requested from tray menu", "TrayIcon");
                await _monitoringService.StopAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to stop from tray");
            }
        };
        contextMenu.Items.Add(stopItem);

        contextMenu.Items.Add(new Separator());

        // Open Dashboard menu item
        var openItem = new MenuItem { Header = "📊 Open Dashboard" };
        openItem.Click += (s, e) =>
        {
            try
            {
                var mainWindow = Application.Current.MainWindow;
                if (mainWindow != null)
                {
                    mainWindow.Show();
                    mainWindow.WindowState = WindowState.Normal;
                    mainWindow.Activate();
                    _loggingService.LogInfo("Dashboard opened from tray menu", "TrayIcon");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to open dashboard");
            }
        };
        contextMenu.Items.Add(openItem);

        // Settings menu item (placeholder for future implementation)
        var settingsItem = new MenuItem { Header = "⚙ Settings" };
        settingsItem.Click += (s, e) =>
        {
            ShowNotification("OptiGemini", "Settings dialog coming soon");
            _loggingService.LogInfo("Settings requested from tray menu", "TrayIcon");
        };
        contextMenu.Items.Add(settingsItem);

        contextMenu.Items.Add(new Separator());

        // Exit menu item
        var exitItem = new MenuItem { Header = "Exit" };
        exitItem.Click += (s, e) =>
        {
            _loggingService.LogInfo("Exit requested from tray menu", "TrayIcon");
            Application.Current.Shutdown();
        };
        contextMenu.Items.Add(exitItem);

        // Subscribe to state changes to update menu item states
        _monitoringService.StateChanged += (s, e) =>
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                UpdateMenuItemStates(contextMenu, e.NewState);
            });
        };

        // Initialize menu states
        UpdateMenuItemStates(contextMenu, _monitoringService.CurrentState);

        return contextMenu;
    }

    private void UpdateMenuItemStates(ContextMenu menu, MonitoringState state)
    {
        if (menu.Items[0] is MenuItem startItem)
            startItem.IsEnabled = state == MonitoringState.Idle || state == MonitoringState.Stopped;

        if (menu.Items[1] is MenuItem pauseItem)
            pauseItem.IsEnabled = state == MonitoringState.Running;

        if (menu.Items[2] is MenuItem resumeItem)
            resumeItem.IsEnabled = state == MonitoringState.Paused;

        if (menu.Items[3] is MenuItem stopItem)
            stopItem.IsEnabled = state == MonitoringState.Running || state == MonitoringState.Paused;
    }

    public void Dispose()
    {
        if (_disposed)
            return;

        _updateTimer?.Stop();
        _updateTimer = null;

        if (_monitoringService != null)
        {
            _monitoringService.StateChanged -= OnMonitoringStateChanged;
        }

        _taskbarIcon?.Dispose();
        _disposed = true;
        
        _logger.LogInformation("Tray icon disposed");
    }
}
