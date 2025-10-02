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

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var services = new ServiceCollection();
        ConfigureServices(services);
        _serviceProvider = services.BuildServiceProvider();

        var mainWindow = _serviceProvider.GetRequiredService<MainWindow>();
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
        _serviceProvider?.Dispose();
        base.OnExit(e);
    }
}
