using Microsoft.Extensions.Logging;
using OptiGemini.Desktop.PowerShell;
using System.IO;
using System.Management.Automation;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// PowerShell bridge service that respects Engine.Runspace.Hosted feature flag
/// When Hosted=true: uses RunspaceHarness (embedded)
/// When Hosted=false: launches external pwsh.exe process (fallback)
/// </summary>
public class PowerShellBridge : IPowerShellBridge, IAsyncDisposable
{
    private readonly ILogger<PowerShellBridge> _logger;
    private readonly IConfigurationService _configService;
    private readonly ILoggingService _loggingService;
    private RunspaceHarness? _runspaceHarness;
    private bool _isInitialized;

    public bool IsInitialized => _isInitialized;

    public PowerShellBridge(
        ILogger<PowerShellBridge> logger,
        IConfigurationService configService,
        ILoggingService loggingService)
    {
        _logger = logger;
        _configService = configService;
        _loggingService = loggingService;
    }

    public async Task InitializeAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var isHostedMode = _configService.Current.Engine.Runspace.Hosted;
            
            if (isHostedMode)
            {
                _loggingService.LogInfo("Initializing hosted PowerShell runspace", "PowerShellBridge");
                await InitializeHostedRunspaceAsync(cancellationToken).ConfigureAwait(false);
            }
            else
            {
                _loggingService.LogInfo("Hosted runspace disabled, will use external pwsh.exe", "PowerShellBridge");
                // External process mode - no initialization needed, will spawn on demand
            }

            _isInitialized = true;
            _loggingService.LogInfo($"PowerShell bridge initialized (Hosted={isHostedMode})", "PowerShellBridge");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initialize PowerShell bridge");
            _loggingService.LogError($"PowerShell bridge initialization failed: {ex.Message}", "PowerShellBridge");
            throw;
        }
    }

    private async Task InitializeHostedRunspaceAsync(CancellationToken cancellationToken)
    {
        // Determine module path - for now use placeholder
        // TODO: Point to actual OptiGemini.psm1 when PowerShell module is ready
        var modulePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Modules", "OptiGemini.psm1");
        
        _runspaceHarness = new RunspaceHarness(modulePath, _logger);
        await _runspaceHarness.InitializeAsync(cancellationToken).ConfigureAwait(false);
    }

    public async Task<T?> InvokeAsync<T>(string command, IDictionary<string, object?>? parameters = null, CancellationToken cancellationToken = default)
    {
        if (!_isInitialized)
        {
            throw new InvalidOperationException("PowerShell bridge is not initialized");
        }

        var isHostedMode = _configService.Current.Engine.Runspace.Hosted;

        try
        {
            if (isHostedMode)
            {
                return await InvokeHostedAsync<T>(command, parameters, cancellationToken).ConfigureAwait(false);
            }
            else
            {
                return await InvokeExternalAsync<T>(command, parameters, cancellationToken).ConfigureAwait(false);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "PowerShell invocation failed: {Command}", command);
            _loggingService.LogError($"PowerShell command failed: {command} - {ex.Message}", "PowerShellBridge");
            throw;
        }
    }

    private async Task<T?> InvokeHostedAsync<T>(string command, IDictionary<string, object?>? parameters, CancellationToken cancellationToken)
    {
        if (_runspaceHarness is null)
        {
            throw new InvalidOperationException("Runspace harness is not initialized");
        }

        var result = await _runspaceHarness.InvokeAsync(command, parameters, cancellationToken).ConfigureAwait(false);
        
        if (result is null)
        {
            return default;
        }

        // Attempt to convert PSObject to requested type
        try
        {
            if (typeof(T) == typeof(PSObject))
            {
                return (T)(object)result;
            }
            
            return (T)Convert.ChangeType(result.BaseObject, typeof(T));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to convert PowerShell result to {Type}", typeof(T).Name);
            return default;
        }
    }

    private async Task<T?> InvokeExternalAsync<T>(string command, IDictionary<string, object?>? parameters, CancellationToken cancellationToken)
    {
        // TODO: Implement external pwsh.exe process execution
        // This is the fallback mode when Engine.Runspace.Hosted = false
        _logger.LogWarning("External PowerShell execution not yet implemented");
        _loggingService.LogWarning("External PowerShell mode requested but not yet implemented", "PowerShellBridge");
        
        await Task.CompletedTask.ConfigureAwait(false);
        return default;
    }

    public async Task ShutdownAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            _loggingService.LogInfo("Shutting down PowerShell bridge", "PowerShellBridge");

            if (_runspaceHarness is not null)
            {
                await _runspaceHarness.DisposeAsync().ConfigureAwait(false);
                _runspaceHarness = null;
            }

            _isInitialized = false;
            _loggingService.LogInfo("PowerShell bridge shutdown complete", "PowerShellBridge");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during PowerShell bridge shutdown");
            _loggingService.LogError($"Shutdown error: {ex.Message}", "PowerShellBridge");
        }
    }

    public async ValueTask DisposeAsync()
    {
        await ShutdownAsync().ConfigureAwait(false);
    }
}
