using Hardcodet.Wpf.TaskbarNotification;
using Microsoft.Extensions.Logging;
using OptiGemini.Desktop.Models;
using System.Windows;
using System.Windows.Controls;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// System tray icon service with context menu and notifications
/// </summary>
public class TrayIconService : ITrayIconService, IDisposable
{
    private readonly ILogger<TrayIconService> _logger;
    private readonly IMonitoringService _monitoringService;
    private readonly ILoggingService _loggingService;
    private TaskbarIcon? _taskbarIcon;
    private bool _disposed;

    public TrayIconService(
        ILogger<TrayIconService> logger,
        IMonitoringService monitoringService,
        ILoggingService loggingService)
    {
        _logger = logger;
        _monitoringService = monitoringService;
        _loggingService = loggingService;
    }

    public void Initialize()
    {
        try
        {
            _taskbarIcon = new TaskbarIcon
            {
                ToolTipText = "OptiGemini - Idle",
                IconSource = CreateDefaultIcon(),
                ContextMenu = CreateContextMenu()
            };

            _taskbarIcon.TrayLeftMouseDown += (s, e) =>
            {
                // Show main window on left click
                Application.Current.MainWindow?.Show();
                Application.Current.MainWindow?.Activate();
            };

            _logger.LogInformation("Tray icon initialized");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initialize tray icon");
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

    private System.Windows.Media.ImageSource CreateDefaultIcon()
    {
        // Create a simple blue circle icon
        // In production, load from embedded resource
        var drawingGroup = new System.Windows.Media.DrawingGroup();
        var geometryDrawing = new System.Windows.Media.GeometryDrawing
        {
            Brush = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(30, 136, 229)),
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
        var openItem = new MenuItem { Header = "Open Dashboard" };
        openItem.Click += (s, e) =>
        {
            Application.Current.MainWindow?.Show();
            Application.Current.MainWindow?.Activate();
        };
        contextMenu.Items.Add(openItem);

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

        _taskbarIcon?.Dispose();
        _disposed = true;
        
        _logger.LogInformation("Tray icon disposed");
    }
}
