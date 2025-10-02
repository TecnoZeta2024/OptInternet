using Microsoft.Extensions.Logging;
using OptiGemini.Desktop.Models;
using System.ComponentModel;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// Core monitoring service with state machine: Idle → Starting → Running → Pausing → Paused → Stopping → Stopped
/// Thread-safe implementation with proper cancellation token support
/// </summary>
public class MonitoringService : IMonitoringService, IDisposable
{
    private readonly ILogger<MonitoringService> _logger;
    private readonly ILoggingService _loggingService;
    private readonly IPowerShellBridge _powerShellBridge;
    private readonly IConfigurationService _configService;
    private readonly SemaphoreSlim _stateLock = new(1, 1);
    private MonitoringState _currentState = MonitoringState.Idle;
    private CancellationTokenSource? _monitoringCts;
    private Task? _monitoringTask;

    public MonitoringState CurrentState
    {
        get
        {
            _stateLock.Wait();
            try
            {
                return _currentState;
            }
            finally
            {
                _stateLock.Release();
            }
        }
    }

    public event EventHandler<StateChangedEventArgs>? StateChanged;
    public event EventHandler<MonitoringErrorEventArgs>? ErrorOccurred;

    public MonitoringService(
        ILogger<MonitoringService> logger,
        ILoggingService loggingService,
        IPowerShellBridge powerShellBridge,
        IConfigurationService configService)
    {
        _logger = logger;
        _loggingService = loggingService;
        _powerShellBridge = powerShellBridge;
        _configService = configService;
    }

    public async Task StartAsync(CancellationToken cancellationToken = default)
    {
        await _stateLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            // Validate state transition
            if (_currentState != MonitoringState.Idle && _currentState != MonitoringState.Stopped)
            {
                var message = $"Cannot start from state {_currentState}";
                _logger.LogWarning(message);
                _loggingService.LogWarning(message, "MonitoringService");
                return;
            }

            await TransitionToStateAsync(MonitoringState.Starting, cancellationToken).ConfigureAwait(false);

            // Initialize PowerShell bridge if not already initialized
            if (!_powerShellBridge.IsInitialized)
            {
                _loggingService.LogInfo("Initializing PowerShell bridge...", "MonitoringService");
                await _powerShellBridge.InitializeAsync(cancellationToken).ConfigureAwait(false);
            }

            // Create new cancellation token source for monitoring loop
            _monitoringCts = new CancellationTokenSource();
            
            await TransitionToStateAsync(MonitoringState.Running, cancellationToken).ConfigureAwait(false);
            _loggingService.LogInfo("Monitoring started successfully", "MonitoringService");

            // Start monitoring loop in background
            _monitoringTask = Task.Run(() => MonitoringLoopAsync(_monitoringCts.Token), _monitoringCts.Token);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to start monitoring");
            _loggingService.LogError($"Start failed: {ex.Message}", "MonitoringService");
            await TransitionToStateAsync(MonitoringState.Stopped, cancellationToken).ConfigureAwait(false);
            OnErrorOccurred(ex);
            throw;
        }
        finally
        {
            _stateLock.Release();
        }
    }

    public async Task StopAsync(CancellationToken cancellationToken = default)
    {
        await _stateLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            // Validate state transition
            if (_currentState == MonitoringState.Idle || _currentState == MonitoringState.Stopped)
            {
                _logger.LogDebug("Already stopped, ignoring stop request");
                return;
            }

            await TransitionToStateAsync(MonitoringState.Stopping, cancellationToken).ConfigureAwait(false);
            _loggingService.LogInfo("Stopping monitoring...", "MonitoringService");

            // Cancel monitoring loop
            _monitoringCts?.Cancel();
            
            // Wait for monitoring task to complete (with timeout)
            if (_monitoringTask != null)
            {
                try
                {
                    await _monitoringTask.WaitAsync(TimeSpan.FromSeconds(5), cancellationToken).ConfigureAwait(false);
                }
                catch (TimeoutException)
                {
                    _logger.LogWarning("Monitoring task did not complete within timeout");
                }
            }

            // Cleanup
            _monitoringCts?.Dispose();
            _monitoringCts = null;
            _monitoringTask = null;

            await TransitionToStateAsync(MonitoringState.Stopped, cancellationToken).ConfigureAwait(false);
            _loggingService.LogInfo("Monitoring stopped", "MonitoringService");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during stop");
            _loggingService.LogError($"Stop error: {ex.Message}", "MonitoringService");
            OnErrorOccurred(ex);
            throw;
        }
        finally
        {
            _stateLock.Release();
        }
    }

    public async Task PauseAsync(CancellationToken cancellationToken = default)
    {
        await _stateLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            // Validate state transition
            if (_currentState != MonitoringState.Running)
            {
                var message = $"Cannot pause from state {_currentState}";
                _logger.LogWarning(message);
                _loggingService.LogWarning(message, "MonitoringService");
                return;
            }

            await TransitionToStateAsync(MonitoringState.Pausing, cancellationToken).ConfigureAwait(false);
            _loggingService.LogInfo("Pausing monitoring...", "MonitoringService");

            // Cancel current monitoring cycle but keep infrastructure alive
            _monitoringCts?.Cancel();

            await TransitionToStateAsync(MonitoringState.Paused, cancellationToken).ConfigureAwait(false);
            _loggingService.LogInfo("Monitoring paused", "MonitoringService");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during pause");
            _loggingService.LogError($"Pause error: {ex.Message}", "MonitoringService");
            OnErrorOccurred(ex);
            throw;
        }
        finally
        {
            _stateLock.Release();
        }
    }

    public async Task ResumeAsync(CancellationToken cancellationToken = default)
    {
        await _stateLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            // Validate state transition
            if (_currentState != MonitoringState.Paused)
            {
                var message = $"Cannot resume from state {_currentState}";
                _logger.LogWarning(message);
                _loggingService.LogWarning(message, "MonitoringService");
                return;
            }

            _loggingService.LogInfo("Resuming monitoring...", "MonitoringService");

            // Create new cancellation token and restart monitoring loop
            _monitoringCts = new CancellationTokenSource();
            
            await TransitionToStateAsync(MonitoringState.Running, cancellationToken).ConfigureAwait(false);
            _loggingService.LogInfo("Monitoring resumed", "MonitoringService");

            // Restart monitoring loop
            _monitoringTask = Task.Run(() => MonitoringLoopAsync(_monitoringCts.Token), _monitoringCts.Token);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during resume");
            _loggingService.LogError($"Resume error: {ex.Message}", "MonitoringService");
            OnErrorOccurred(ex);
            throw;
        }
        finally
        {
            _stateLock.Release();
        }
    }

    private async Task MonitoringLoopAsync(CancellationToken cancellationToken)
    {
        var config = _configService.Current.Monitoring;
        var intervalMs = config.CheckIntervalSeconds * 1000;

        _logger.LogInformation("Monitoring loop started with {Interval}ms interval", intervalMs);

        try
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    // Invoke PowerShell monitoring function
                    // TODO: Implement actual monitoring logic when PowerShell functions are ready
                    await Task.Delay(intervalMs, cancellationToken).ConfigureAwait(false);
                    
                    _logger.LogDebug("Monitoring cycle completed");
                }
                catch (OperationCanceledException)
                {
                    // Expected during pause/stop
                    _logger.LogDebug("Monitoring cycle cancelled");
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in monitoring cycle");
                    _loggingService.LogError($"Monitoring error: {ex.Message}", "MonitoringService");
                    OnErrorOccurred(ex);
                }
            }
        }
        finally
        {
            _logger.LogInformation("Monitoring loop exited");
        }
    }

    private async Task TransitionToStateAsync(MonitoringState newState, CancellationToken cancellationToken)
    {
        var previousState = _currentState;
        _currentState = newState;

        _logger.LogInformation("State transition: {Previous} → {New}", previousState, newState);

        var eventArgs = new StateChangedEventArgs
        {
            PreviousState = previousState,
            NewState = newState,
            Timestamp = DateTime.Now
        };

        // Raise event on UI thread if possible
        await Task.Run(() => StateChanged?.Invoke(this, eventArgs), cancellationToken).ConfigureAwait(false);
    }

    private void OnErrorOccurred(Exception ex)
    {
        ErrorOccurred?.Invoke(this, new MonitoringErrorEventArgs(ex));
    }

    public void Dispose()
    {
        _monitoringCts?.Cancel();
        _monitoringCts?.Dispose();
        _stateLock.Dispose();
    }
}
