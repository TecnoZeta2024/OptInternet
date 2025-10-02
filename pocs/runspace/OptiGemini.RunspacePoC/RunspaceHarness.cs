using System.Collections.Concurrent;
using System.Diagnostics;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using Microsoft.Extensions.Logging;
using OptiGemini.RunspacePoC.Telemetry;

namespace OptiGemini.RunspacePoC;

internal sealed class RunspaceHarness : IAsyncDisposable
{
    private readonly ILogger _logger;
    private readonly string _modulePath;
    private Runspace? _runspace;
    private readonly SemaphoreSlim _runspaceLock = new(1, 1);
    private readonly ConcurrentQueue<double> _latencySamples = new();

    public RunspaceHarness(string modulePath, ILogger logger)
    {
        _modulePath = modulePath;
        _logger = logger;
    }

    public IReadOnlyCollection<double> LatencySamples => _latencySamples.ToArray();

    public async Task InitializeAsync(CancellationToken cancellationToken)
    {
        await _runspaceLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            await CreateRunspaceAsync(cancellationToken).ConfigureAwait(false);
        }
        finally
        {
            _runspaceLock.Release();
        }
    }

    private async Task CreateRunspaceAsync(CancellationToken cancellationToken)
    {
        DisposeRunspace();

        using var initialState = InitialSessionState.CreateDefault2();
        initialState.ImportPSModule(new[] { _modulePath });

        _runspace = RunspaceFactory.CreateRunspace(initialState);
        _runspace.Open();

        await Task.CompletedTask.ConfigureAwait(false);
        _logger.LogInformation("Runspace created and module imported from {ModulePath}.", _modulePath);
    }

    public async Task<PSObject?> InvokeAsync(string command, IDictionary<string, object?>? parameters, CancellationToken cancellationToken)
    {
        await _runspaceLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            if (_runspace is null)
            {
                throw new InvalidOperationException("Runspace has not been initialized.");
            }

            using var ps = PowerShell.Create();
            ps.Runspace = _runspace;
            ps.AddCommand(command);

            if (parameters is not null)
            {
                foreach (var kvp in parameters)
                {
                    ps.AddParameter(kvp.Key, kvp.Value);
                }
            }

            var stopwatch = Stopwatch.StartNew();

            try
            {
                _logger.LogDebug("Invoking {Command}...", command);
                var results = await ps.InvokeAsync().ConfigureAwait(false);
                stopwatch.Stop();
                _latencySamples.Enqueue(stopwatch.Elapsed.TotalMilliseconds);

                if (ps.HadErrors)
                {
                    var errors = string.Join("; ", ps.Streams.Error.Select(e => e.ToString()));
                    _logger.LogError("Command {Command} reported errors: {Errors}", command, errors);
                }

                _logger.LogInformation("{Command} completed in {Elapsed:F2} ms", command, stopwatch.Elapsed.TotalMilliseconds);
                return results.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Command {Command} failed after {Elapsed:F2} ms", command, stopwatch.Elapsed.TotalMilliseconds);
                throw;
            }
        }
        finally
        {
            _runspaceLock.Release();
        }
    }

    public async Task RestartAsync(CancellationToken cancellationToken)
    {
        await _runspaceLock.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            _logger.LogWarning("Restarting runspace on watchdog request.");
            await CreateRunspaceAsync(cancellationToken).ConfigureAwait(false);
        }
        finally
        {
            _runspaceLock.Release();
        }
    }

    public ValueTask DisposeAsync()
    {
        DisposeRunspace();
        _runspaceLock.Dispose();
        return ValueTask.CompletedTask;
    }

    private void DisposeRunspace()
    {
        try
        {
            _runspace?.Dispose();
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error while disposing runspace.");
        }
        finally
        {
            _runspace = null;
        }
    }
}