namespace OptiGemini.Desktop.Models;

/// <summary>
/// Represents the overall connection health status
/// </summary>
public enum ConnectionStatus
{
    /// <summary>Connection is working optimally</summary>
    Optimal,

    /// <summary>Connection is degraded but functional</summary>
    Degraded,

    /// <summary>No connection available</summary>
    Offline
}
