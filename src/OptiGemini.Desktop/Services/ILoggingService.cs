using OptiGemini.Desktop.Models;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// Service interface for application-level logging
/// </summary>
public interface ILoggingService
{
    /// <summary>Log an informational message</summary>
    void LogInfo(string message, string? source = null);

    /// <summary>Log a warning message</summary>
    void LogWarning(string message, string? source = null);

    /// <summary>Log an error message</summary>
    void LogError(string message, string? source = null);

    /// <summary>Log a system-level message</summary>
    void LogSystem(string message, string? source = null);

    /// <summary>Raised when a new log entry is created</summary>
    event EventHandler<LogEntry>? LogEntryAdded;

    /// <summary>Get recent log entries</summary>
    IReadOnlyList<LogEntry> GetRecentEntries(int count = 100);
}
