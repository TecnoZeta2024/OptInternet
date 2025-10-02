namespace OptiGemini.Desktop.Models;

/// <summary>
/// Represents the current state of the monitoring service
/// </summary>
public enum MonitoringState
{
    /// <summary>Service is not running</summary>
    Idle,

    /// <summary>Service is initializing</summary>
    Starting,

    /// <summary>Service is actively monitoring</summary>
    Running,

    /// <summary>Service is transitioning to paused state</summary>
    Pausing,

    /// <summary>Service is paused</summary>
    Paused,

    /// <summary>Service is shutting down</summary>
    Stopping,

    /// <summary>Service has stopped</summary>
    Stopped
}
