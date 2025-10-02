using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using OptiGemini.Desktop.Services;
using OptiGemini.Desktop.ViewModels;
using OptiGemini.Desktop.Views;
using System.Windows;

namespace OptiGemini.Desktop;

/// <summary>
/// Application entry point with dependency injection configuration
/// </summary>
public partial class App : Application
{
    private ServiceProvider? _serviceProvider;
    private ITrayIconService? _trayIconService;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var services = new ServiceCollection();
        ConfigureServices(services);
        _serviceProvider = services.BuildServiceProvider();

        // Initialize tray icon before showing main window
        _trayIconService = _serviceProvider.GetRequiredService<ITrayIconService>();
        _trayIconService.Initialize();

        var mainWindow = _serviceProvider.GetRequiredService<MainWindow>();
        
        // Configure main window to minimize to tray instead of closing
        mainWindow.Closing += OnMainWindowClosing;
        
        mainWindow.Show();
    }

    private void ConfigureServices(IServiceCollection services)
    {
        // Logging
        services.AddLogging(builder =>
        {
            builder.AddConsole();
            builder.AddDebug();
            builder.SetMinimumLevel(LogLevel.Information);
        });

        // Services
        services.AddSingleton<IConfigurationService, ConfigurationService>();
        services.AddSingleton<ILoggingService, LoggingService>();
        services.AddSingleton<IPowerShellBridge, PowerShellBridge>();
        services.AddSingleton<IMonitoringService, MonitoringService>();
        services.AddSingleton<ITrayIconService, TrayIconService>();

        // ViewModels
        services.AddTransient<MainWindowViewModel>();

        // Views
        services.AddTransient<MainWindow>();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        // Properly dispose monitoring service before app exit
        var monitoringService = _serviceProvider?.GetService<IMonitoringService>();
        if (monitoringService != null)
        {
            try
            {
                // Stop monitoring synchronously on exit
                monitoringService.StopAsync().GetAwaiter().GetResult();
            }
            catch
            {
                // Ignore errors during shutdown
            }
        }

        _trayIconService?.Dispose();
        _serviceProvider?.Dispose();
        base.OnExit(e);
    }

    private void OnMainWindowClosing(object? sender, System.ComponentModel.CancelEventArgs e)
    {
        // Prevent actual close, just hide the window
        e.Cancel = true;
        if (sender is Window window)
        {
            window.Hide();
            _trayIconService?.ShowNotification("OptiGemini", "Application minimized to system tray");
        }
    }
}
