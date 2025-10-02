using Microsoft.Extensions.Logging;
using OptiGemini.Desktop.Models;
using System.Collections.Concurrent;
using System.IO;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// Application-level logging service with event broadcasting and file persistence
/// </summary>
public class LoggingService : ILoggingService
{
    private readonly ILogger<LoggingService> _logger;
    private readonly ConcurrentQueue<LogEntry> _logEntries = new();
    private readonly string _logFilePath;
    private readonly SemaphoreSlim _fileLock = new(1, 1);
    private const int MaxInMemoryEntries = 1000;

    public event EventHandler<LogEntry>? LogEntryAdded;

    public LoggingService(ILogger<LoggingService> logger)
    {
        _logger = logger;
        
        var appDataPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        var logDir = Path.Combine(appDataPath, "OptiGemini", "Logs");
        Directory.CreateDirectory(logDir);
        
        _logFilePath = Path.Combine(logDir, $"OptiGemini_{DateTime.Now:yyyyMMdd}.log");
    }

    public void LogInfo(string message, string? source = null)
    {
        AddLogEntry(Models.LogLevel.INFO, message, source);
    }

    public void LogWarning(string message, string? source = null)
    {
        AddLogEntry(Models.LogLevel.WARN, message, source);
    }

    public void LogError(string message, string? source = null)
    {
        AddLogEntry(Models.LogLevel.ERROR, message, source);
    }

    public void LogSystem(string message, string? source = null)
    {
        AddLogEntry(Models.LogLevel.SYSTEM, message, source);
    }

    public IReadOnlyList<LogEntry> GetRecentEntries(int count = 100)
    {
        return _logEntries.TakeLast(count).ToList();
    }

    private void AddLogEntry(Models.LogLevel level, string message, string? source)
    {
        var entry = new LogEntry
        {
            Timestamp = DateTime.Now,
            Level = level,
            Message = message,
            Source = source
        };

        _logEntries.Enqueue(entry);

        // Trim old entries to prevent memory growth
        while (_logEntries.Count > MaxInMemoryEntries)
        {
            _logEntries.TryDequeue(out _);
        }

        // Write to file asynchronously
        _ = Task.Run(() => WriteToFileAsync(entry));

        // Broadcast to subscribers
        LogEntryAdded?.Invoke(this, entry);

        // Also log to framework logger
        switch (level)
        {
            case Models.LogLevel.INFO:
                _logger.LogInformation("[{Source}] {Message}", source ?? "App", message);
                break;
            case Models.LogLevel.WARN:
                _logger.LogWarning("[{Source}] {Message}", source ?? "App", message);
                break;
            case Models.LogLevel.ERROR:
                _logger.LogError("[{Source}] {Message}", source ?? "App", message);
                break;
            case Models.LogLevel.SYSTEM:
                _logger.LogInformation("[SYSTEM] [{Source}] {Message}", source ?? "App", message);
                break;
        }
    }

    private async Task WriteToFileAsync(LogEntry entry)
    {
        await _fileLock.WaitAsync().ConfigureAwait(false);
        try
        {
            await File.AppendAllTextAsync(_logFilePath, entry.ToString() + Environment.NewLine).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to write log entry to file");
        }
        finally
        {
            _fileLock.Release();
        }
    }
}
