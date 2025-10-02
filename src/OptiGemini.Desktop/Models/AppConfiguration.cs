namespace OptiGemini.Desktop.Models;

/// <summary>
/// Configuration model loaded from %APPDATA%/OptiGemini/config.json
/// </summary>
public class AppConfiguration
{
    public EngineConfiguration Engine { get; set; } = new();
    public MonitoringConfiguration Monitoring { get; set; } = new();
    public LoggingConfiguration Logging { get; set; } = new();
}

public class EngineConfiguration
{
    public RunspaceConfiguration Runspace { get; set; } = new();
}

public class RunspaceConfiguration
{
    /// <summary>
    /// Feature flag: true = hosted runspace, false = external pwsh.exe
    /// </summary>
    public bool Hosted { get; set; } = true;
}

public class MonitoringConfiguration
{
    public string PrimaryCheckAddress { get; set; } = "8.8.8.8";
    public string SecondaryCheckAddress { get; set; } = "1.1.1.1";
    public string TertiaryCheckAddress { get; set; } = "208.67.222.222";
    public int CheckIntervalSeconds { get; set; } = 3;
    public int MaxRetries { get; set; } = 5;
    public int LatencyThreshold { get; set; } = 150;
}

public class LoggingConfiguration
{
    public string LogLevel { get; set; } = "Information";
    public string LogFilePath { get; set; } = "";
}
