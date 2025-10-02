namespace OptiGemini.Desktop.Models;

/// <summary>
/// Represents a log entry for display and persistence
/// </summary>
public class LogEntry
{
    public DateTime Timestamp { get; set; }
    public LogLevel Level { get; set; }
    public string Message { get; set; } = string.Empty;
    public string? Source { get; set; }
    
    public override string ToString()
    {
        return $"[{Timestamp:yyyy-MM-dd HH:mm:ss}] [{Level}] {Message}";
    }
}

/// <summary>
/// Log severity levels
/// </summary>
public enum LogLevel
{
    INFO,
    WARN,
    ERROR,
    SYSTEM
}
