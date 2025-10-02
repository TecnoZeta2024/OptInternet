using OptiGemini.Desktop.Models;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// Service interface for PowerShell script execution
/// </summary>
public interface IPowerShellBridge
{
    /// <summary>Initialize PowerShell runspace or external process</summary>
    Task InitializeAsync(CancellationToken cancellationToken = default);

    /// <summary>Execute a PowerShell command</summary>
    Task<T?> InvokeAsync<T>(string command, IDictionary<string, object?>? parameters = null, CancellationToken cancellationToken = default);

    /// <summary>Shutdown and cleanup PowerShell resources</summary>
    Task ShutdownAsync(CancellationToken cancellationToken = default);

    /// <summary>Check if bridge is initialized</summary>
    bool IsInitialized { get; }
}
