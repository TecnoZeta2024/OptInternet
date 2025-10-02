using OptiGemini.Desktop.Models;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// Service interface for monitoring network operations with state machine control
/// </summary>
public interface IMonitoringService
{
    /// <summary>Current monitoring state</summary>
    MonitoringState CurrentState { get; }

    /// <summary>Raised when monitoring state changes</summary>
    event EventHandler<StateChangedEventArgs>? StateChanged;

    /// <summary>Raised when an error occurs</summary>
    event EventHandler<ErrorEventArgs>? ErrorOccurred;

    /// <summary>Start monitoring operations</summary>
    Task StartAsync(CancellationToken cancellationToken = default);

    /// <summary>Stop monitoring operations</summary>
    Task StopAsync(CancellationToken cancellationToken = default);

    /// <summary>Pause monitoring operations</summary>
    Task PauseAsync(CancellationToken cancellationToken = default);

    /// <summary>Resume monitoring from paused state</summary>
    Task ResumeAsync(CancellationToken cancellationToken = default);
}

/// <summary>
/// Event arguments for state changes
/// </summary>
public class StateChangedEventArgs : EventArgs
{
    public MonitoringState PreviousState { get; set; }
    public MonitoringState NewState { get; set; }
    public DateTime Timestamp { get; set; }
}
