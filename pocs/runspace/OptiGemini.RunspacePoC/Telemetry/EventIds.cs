namespace OptiGemini.RunspacePoC.Telemetry;

internal static class EventIds
{
    public const int RunspaceInvokeStart = 1001;
    public const int RunspaceInvokeCompleted = 1002;
    public const int RunspaceInvokeFault = 1003;
    public const int RunspaceRestarted = 1100;
    public const int WatchdogHeartbeat = 1101;
}