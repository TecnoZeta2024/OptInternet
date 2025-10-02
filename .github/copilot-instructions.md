# OptiGemini v2.2 - AI Coding Instructions

## Project Overview
OptiGemini is a sophisticated PowerShell-based network optimization and monitoring tool with real-time dashboard visualization. The main script (`OpTinternet.ps1`) provides comprehensive network diagnostics, automatic recovery, hotspot management, and performance optimization.

## Project Mission 🚀
The primary objective of this repository is to **transform the existing PowerShell script (`OpTinternet.ps1`) into a professional-quality desktop application for Windows 11**. This evolution aims to:

- **Modernize the User Interface**: Replace console-based dashboard with a native Windows 11 GUI
- **Enhance User Experience**: Implement intuitive controls, visual indicators, and responsive design
- **Maintain Core Functionality**: Preserve all network optimization and monitoring capabilities
- **Add Professional Features**: Include system tray integration, notifications, configuration management
- **Ensure Windows 11 Compatibility**: Leverage modern Windows APIs and design principles
- **Create Distribution-Ready Package**: Prepare for installer creation and deployment

### Development Phases
1. **Phase 1**: Maintain PowerShell core while adding WPF/WinUI frontend
2. **Phase 2**: Implement modern Windows 11 design system and interactions  
3. **Phase 3**: Add advanced features (scheduling, profiles, remote monitoring)
4. **Phase 4**: Package as distributable Windows application with installer

## Architecture Patterns

### Core Structure
- **Single-file monolith**: All functionality in `OpTinternet.ps1` (1736 lines)
- **Region-based organization**: Code organized with `#region` blocks for logical separation
- **State management**: Heavy use of `$script:` scoped variables for global state
- **Event-driven monitoring**: Continuous monitoring loop with adaptive recovery

### Dashboard Architecture
The dashboard uses a unique two-phase rendering approach:
```powershell
# Static structure drawn once, dynamic content updated in-place
Show-StaticDashboard      # Draws UI framework
Update-DynamicFields      # Updates live metrics
Update-LogArea           # Updates scrolling log section
```

### Key Architectural Decisions
- **Console-based UI**: Custom cursor positioning and colored output for real-time dashboard
- **Dual DNS failover**: Primary (8.8.8.8) → Secondary (1.1.1.1) → Tertiary (OpenDNS)
- **Adaptive retry logic**: Escalating recovery strategies based on failure patterns
- **Performance history tracking**: Maintains metrics over time for trend analysis

## Critical Development Patterns

### Error Handling Convention
```powershell
try {
    # Main operation
    Write-Log -Message "Operation description" -Level "INFO"
}
catch {
    $errorMessage = "Context: $($_.Exception.Message)"
    Write-Log -Message $errorMessage -Level "ERROR"
    # Graceful degradation logic
}
```

### Safe Console Operations
Always validate console dimensions and use safe multipliers:
```powershell
$safeWidth = [Math]::Max(1, $minWidth - 1)
$clearLength = [Math]::Max(0, $Message.Length + 4)
```

### Network Testing Pattern
Multi-tier connectivity verification with specific retry logic:
```powershell
# Test primary → secondary → tertiary addresses
# Each with configurable thresholds for latency, packet loss, jitter
```

## Development Workflows

### Running the Script
- **Required**: Administrator privileges (script validates and exits if not admin)
- **Console requirements**: Minimum 80x30 characters (validated by `Test-ConsoleSize`)
- **Encoding setup**: UTF-8 encoding configured automatically

### Key Configuration Variables
Located in the `VARIABLES Y CONFIGURACION INICIAL` region:
- `$SSID/$Password`: Hotspot credentials
- `$CheckIntervalSeconds`: Monitoring frequency (default: 3s)
- `$LatencyThreshold`: Performance threshold (default: 150ms)
- DNS servers and retry parameters

### Logging System
- **Log file**: `OptiGemini_log.txt` in script directory
- **Levels**: SYSTEM, INFO, WARN, ERROR
- **Format**: `[timestamp] [level] - message`

## Function Categories

### Core Functions
- `Test-ConsoleSize`: Validates terminal dimensions
- `Write-Log`: Centralized logging with timestamp
- `Set-ConsoleEncoding`: UTF-8 setup for special characters

### Dashboard Functions
- `Show-PremiumDashboard`: Main dashboard controller
- `Show-StaticDashboard`: UI framework rendering
- `Update-DynamicFields`: Live metric updates
- `Set-CursorPosition`: Console positioning utility

### Network Functions
- `Test-InternetConnection`: Multi-tier connectivity testing
- `Get-NetworkMetrics`: Performance measurement
- `Restart-InternetAdapter`: Intelligent adapter recovery
- `Set-FastestDNS`: Automatic DNS optimization

### Optimization Functions
- `Optimize-NetworkSettings`: Registry-based network tuning
- `Set-IntelligentQoS`: Traffic prioritization
- `Optimize-TCPIPSettings`: TCP/IP stack optimization

## Project-Specific Conventions

### Variable Naming
- `$script:` prefix for global state variables
- PascalCase for configuration constants
- Descriptive names with context (e.g., `$script:totalDowntimeStopwatch`)

### Function Organization
- Functions prefixed with action verbs: `Test-`, `Get-`, `Set-`, `Show-`, `Update-`
- Helper functions marked with `# >> FUNCION AUXILIAR:`
- Main functions marked with `# >> FUNCION PRINCIPAL:`

### Console UI Patterns
- Extensive use of `Write-Host` with `-ForegroundColor` for colored output
- Padded fields with consistent spacing using custom `Write-PaddedField`
- Progress bars using custom `Get-Bar` function with Unicode characters

## Integration Points

### Windows System Integration
- **WMI/CIM queries**: System metrics via `Get-CimInstance`
- **Network adapters**: Direct manipulation via `Get-NetAdapter`, `Set-DnsClientServerAddress`
- **Registry modifications**: Network optimization via registry keys
- **Windows services**: Hotspot management via `netsh wlan` commands

### External Dependencies
- **No external modules required**: Uses only built-in PowerShell cmdlets
- **Network tools**: Relies on `ping`, `tracert`, and built-in network cmdlets
- **System commands**: Integrates with `netsh`, registry operations

## Performance Considerations
- **Dashboard refresh optimization**: Static UI drawn once, only dynamic content updates
- **Metric caching**: Expensive operations cached with time-based invalidation  
- **Memory management**: Periodic cleanup of performance history arrays
- **Network efficiency**: Adaptive polling intervals based on connection stability

## Clean Code Best Practices

### Function Design
- **Single Responsibility**: Each function should have one clear purpose
- **Descriptive Naming**: Use action verbs with clear context (e.g., `Test-InternetConnection`, `Optimize-NetworkSettings`)
- **Function Size**: Keep functions focused and manageable (~50-100 lines max)
- **Parameter Validation**: Always validate inputs and provide meaningful error messages

### Code Organization
```powershell
# Use regions for logical separation
#region NETWORK FUNCTIONS
function Test-InternetConnection { }
function Get-NetworkMetrics { }
#endregion

# Group related functionality together
# Comment function purpose and usage
# >> FUNCION PRINCIPAL: Main network testing logic
```

### Variable and State Management
- **Meaningful Names**: `$script:totalDowntimeStopwatch` instead of `$script:timer`
- **Consistent Scoping**: Use `$script:` for global state, local variables for function scope
- **Initialization**: Always initialize variables with default values
- **Type Safety**: Use explicit typing where beneficial `[int]$retries = 0`

### Error Handling Standards
```powershell
# Always provide context in error messages
try {
    # Operation
    Write-Log -Message "Starting network optimization" -Level "INFO"
}
catch {
    $errorMessage = "Network optimization failed: $($_.Exception.Message)"
    Write-Log -Message $errorMessage -Level "ERROR"
    # Provide fallback or graceful degradation
}
```

### Documentation and Comments
- **Function Headers**: Document purpose, parameters, and return values
- **Inline Comments**: Explain complex logic, not obvious code
- **Region Comments**: Clearly define code sections and their responsibilities
- **Change Log**: Document significant modifications with date and reason

## Git Flow Best Practices

### Branch Structure
```
main/master     # Production-ready code
├── develop     # Integration branch for features
├── feature/*   # New features (feature/network-optimization)
├── hotfix/*    # Critical production fixes (hotfix/dns-timeout)
└── release/*   # Release preparation (release/v2.3)
```

### Branch Naming Conventions
- **Features**: `feature/descriptive-name` (e.g., `feature/qos-optimization`)
- **Bug Fixes**: `bugfix/issue-description` (e.g., `bugfix/console-sizing-error`)
- **Hotfixes**: `hotfix/critical-issue` (e.g., `hotfix/memory-leak`)
- **Releases**: `release/version-number` (e.g., `release/v2.3.0`)

### Commit Message Standards
```
feat: add intelligent QoS traffic prioritization
fix: resolve console dimension validation error
docs: update network optimization documentation
refactor: extract dashboard rendering to separate functions
perf: optimize DNS response time measurement
```

### Commit Message Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

### Development Workflow
1. **Start Feature**: `git checkout -b feature/new-feature develop`
2. **Regular Commits**: Small, focused commits with clear messages
3. **Pull Request**: Create PR from feature branch to develop
4. **Code Review**: Ensure code quality and adherence to patterns
5. **Merge**: Squash commits if needed, merge to develop
6. **Release**: Create release branch when ready for production

### PowerShell-Specific Git Practices
- **Line Endings**: Configure Git for Windows line endings (`core.autocrlf=true`)
- **File Encoding**: Ensure UTF-8 encoding for PowerShell files
- **Large Files**: Use `.gitignore` for log files and temporary data
- **Script Testing**: Test scripts on clean systems before committing

### Pre-Commit Checklist
- [ ] Script runs without errors in clean PowerShell session
- [ ] Administrator privileges validated properly
- [ ] Console size requirements met
- [ ] Logging functionality working
- [ ] Network functions tested with different connection states
- [ ] Dashboard renders correctly on different terminal sizes

---

## Byterover MCP Integration

### Knowledge Storage (`byterover-store-knowledge`)
Use when discovering:
- Network optimization techniques and registry tweaks
- Console UI rendering patterns and cursor positioning
- Error handling strategies for network operations
- Performance monitoring and metrics collection patterns

### Knowledge Retrieval (`byterover-retrieve-knowledge`)  
Use when working on:
- Network connectivity and troubleshooting features
- Dashboard UI modifications or new display elements
- System integration and Windows-specific operations
- Performance optimization and monitoring enhancements

[byterover-mcp]

[byterover-mcp]

You are given two tools from Byterover MCP server, including
## 1. `byterover-store-knowledge`
You `MUST` always use this tool when:

+ Learning new patterns, APIs, or architectural decisions from the codebase
+ Encountering error solutions or debugging techniques
+ Finding reusable code patterns or utility functions
+ Completing any significant task or plan implementation

## 2. `byterover-retrieve-knowledge`
You `MUST` always use this tool when:

+ Starting any new task or implementation to gather relevant context
+ Before making architectural decisions to understand existing patterns
+ When debugging issues to check for previous solutions
+ Working with unfamiliar parts of the codebase
