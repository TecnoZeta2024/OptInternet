using System.Diagnostics;
using System.Management.Automation.Runspaces;
using Microsoft.Extensions.Logging;

namespace OptiGemini.RunspacePoC;

internal sealed class RunspaceWatchdog : IDisposable
{
    private readonly TimeSpan _heartbeatInterval;
    private readonly TimeSpan _timeout;
    private readonly Func<Task> _restartCallback;
    private readonly ILogger _logger;
    private readonly Timer _timer;

    private DateTime _lastHeartbeat;
    private bool _disposed;

    public RunspaceWatchdog(TimeSpan heartbeatInterval, TimeSpan timeout, Func<Task> restartCallback, ILogger logger)
    {
        _heartbeatInterval = heartbeatInterval;
        _timeout = timeout;
        _restartCallback = restartCallback;
        _logger = logger;
        _lastHeartbeat = DateTime.UtcNow;
        _timer = new Timer(CheckHealth, null, heartbeatInterval, heartbeatInterval);
    }

    public void Pulse()
    {
        _lastHeartbeat = DateTime.UtcNow;
    }

    private async void CheckHealth(object? state)
    {
        if (_disposed)
        {
            return;
        }

        var elapsed = DateTime.UtcNow - _lastHeartbeat;
        if (elapsed < _timeout)
        {
            return;
        }

        _logger.LogWarning("Runspace heartbeat missed ({ElapsedSeconds:F1}s). Triggering restart.", elapsed.TotalSeconds);
        try
        {
            await _restartCallback().ConfigureAwait(false);
            _lastHeartbeat = DateTime.UtcNow;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to restart runspace after heartbeat failure.");
        }
    }

    public void Dispose()
    {
        if (_disposed)
        {
            return;
        }

        _disposed = true;
        _timer.Dispose();
    }
}