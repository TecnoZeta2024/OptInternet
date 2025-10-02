namespace OptiGemini.Desktop.Services;

/// <summary>
/// Service interface for system tray icon management
/// </summary>
public interface ITrayIconService
{
    /// <summary>Initialize and show tray icon</summary>
    void Initialize();

    /// <summary>Show a toast notification from tray</summary>
    void ShowNotification(string title, string message);

    /// <summary>Update tray icon tooltip</summary>
    void UpdateTooltip(string tooltip);

    /// <summary>Cleanup and hide tray icon</summary>
    void Dispose();
}
