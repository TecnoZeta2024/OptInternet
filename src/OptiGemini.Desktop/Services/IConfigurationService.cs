using OptiGemini.Desktop.Models;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// Service interface for configuration management
/// </summary>
public interface IConfigurationService
{
    /// <summary>Load configuration from file</summary>
    Task<AppConfiguration> LoadAsync();

    /// <summary>Save configuration to file</summary>
    Task SaveAsync(AppConfiguration config);

    /// <summary>Get current configuration</summary>
    AppConfiguration Current { get; }
}
