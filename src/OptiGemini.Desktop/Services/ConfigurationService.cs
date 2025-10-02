using Microsoft.Extensions.Logging;
using OptiGemini.Desktop.Models;
using System.IO;
using System.Text.Json;

namespace OptiGemini.Desktop.Services;

/// <summary>
/// Configuration service that loads/saves from %APPDATA%/OptiGemini/config.json
/// </summary>
public class ConfigurationService : IConfigurationService
{
    private readonly ILogger<ConfigurationService> _logger;
    private readonly string _configPath;
    private AppConfiguration _current;

    public AppConfiguration Current => _current;

    public ConfigurationService(ILogger<ConfigurationService> logger)
    {
        _logger = logger;
        
        var appDataPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        var configDir = Path.Combine(appDataPath, "OptiGemini");
        Directory.CreateDirectory(configDir);
        
        _configPath = Path.Combine(configDir, "config.json");
        _current = new AppConfiguration();
    }

    public async Task<AppConfiguration> LoadAsync()
    {
        try
        {
            if (!File.Exists(_configPath))
            {
                _logger.LogInformation("Config file not found, creating default: {Path}", _configPath);
                _current = new AppConfiguration();
                await SaveAsync(_current).ConfigureAwait(false);
                return _current;
            }

            var json = await File.ReadAllTextAsync(_configPath).ConfigureAwait(false);
            _current = JsonSerializer.Deserialize<AppConfiguration>(json) ?? new AppConfiguration();
            
            _logger.LogInformation("Configuration loaded from {Path}", _configPath);
            return _current;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to load configuration, using defaults");
            _current = new AppConfiguration();
            return _current;
        }
    }

    public async Task SaveAsync(AppConfiguration config)
    {
        try
        {
            var json = JsonSerializer.Serialize(config, new JsonSerializerOptions 
            { 
                WriteIndented = true 
            });
            
            await File.WriteAllTextAsync(_configPath, json).ConfigureAwait(false);
            _current = config;
            
            _logger.LogInformation("Configuration saved to {Path}", _configPath);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to save configuration");
            throw;
        }
    }
}
