using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;
using OptiGemini.Desktop.Models;
using OptiGemini.Desktop.Services;
using Xunit;

namespace OptiGemini.Desktop.Tests.Services;

/// <summary>
/// Unit tests for MonitoringService state machine transitions
/// </summary>
public class MonitoringServiceTests : IDisposable
{
    private readonly Mock<ILogger<MonitoringService>> _mockLogger;
    private readonly Mock<ILoggingService> _mockLoggingService;
    private readonly Mock<IPowerShellBridge> _mockPowerShellBridge;
    private readonly Mock<IConfigurationService> _mockConfigService;
    private readonly MonitoringService _sut;

    public MonitoringServiceTests()
    {
        _mockLogger = new Mock<ILogger<MonitoringService>>();
        _mockLoggingService = new Mock<ILoggingService>();
        _mockPowerShellBridge = new Mock<IPowerShellBridge>();
        _mockConfigService = new Mock<IConfigurationService>();

        // Setup default configuration
        var config = new AppConfiguration();
        _mockConfigService.Setup(x => x.Current).Returns(config);
        _mockPowerShellBridge.Setup(x => x.IsInitialized).Returns(true);

        _sut = new MonitoringService(
            _mockLogger.Object,
            _mockLoggingService.Object,
            _mockPowerShellBridge.Object,
            _mockConfigService.Object);
    }

    [Fact]
    public void InitialState_ShouldBeIdle()
    {
        // Assert
        _sut.CurrentState.Should().Be(MonitoringState.Idle);
    }

    [Fact]
    public async Task StartAsync_FromIdle_ShouldTransitionToRunning()
    {
        // Arrange
        MonitoringState? capturedState = null;
        _sut.StateChanged += (s, e) => capturedState = e.NewState;

        // Act
        await _sut.StartAsync();
        await Task.Delay(100); // Allow state transition to complete

        // Assert
        _sut.CurrentState.Should().Be(MonitoringState.Running);
        capturedState.Should().Be(MonitoringState.Running);
        _mockLoggingService.Verify(x => x.LogInfo(It.IsAny<string>(), "MonitoringService"), Times.AtLeastOnce);
    }

    [Fact]
    public async Task StopAsync_FromRunning_ShouldTransitionToStopped()
    {
        // Arrange
        await _sut.StartAsync();
        await Task.Delay(100);

        // Act
        await _sut.StopAsync();
        await Task.Delay(100);

        // Assert
        _sut.CurrentState.Should().Be(MonitoringState.Stopped);
    }

    [Fact]
    public async Task PauseAsync_FromRunning_ShouldTransitionToPaused()
    {
        // Arrange
        await _sut.StartAsync();
        await Task.Delay(100);

        // Act
        await _sut.PauseAsync();
        await Task.Delay(100);

        // Assert
        _sut.CurrentState.Should().Be(MonitoringState.Paused);
    }

    [Fact]
    public async Task ResumeAsync_FromPaused_ShouldTransitionToRunning()
    {
        // Arrange
        await _sut.StartAsync();
        await Task.Delay(100);
        await _sut.PauseAsync();
        await Task.Delay(100);

        // Act
        await _sut.ResumeAsync();
        await Task.Delay(100);

        // Assert
        _sut.CurrentState.Should().Be(MonitoringState.Running);
    }

    [Fact]
    public async Task StartAsync_WhenAlreadyRunning_ShouldNotChangeState()
    {
        // Arrange
        await _sut.StartAsync();
        await Task.Delay(100);
        var stateBefore = _sut.CurrentState;

        // Act
        await _sut.StartAsync(); // Should be idempotent

        // Assert
        _sut.CurrentState.Should().Be(stateBefore);
        _mockLoggingService.Verify(x => 
            x.LogWarning(It.Is<string>(m => m.Contains("Cannot start")), "MonitoringService"), 
            Times.Once);
    }

    [Fact]
    public async Task PauseAsync_FromNonRunningState_ShouldLogWarning()
    {
        // Act
        await _sut.PauseAsync();

        // Assert
        _mockLoggingService.Verify(x => 
            x.LogWarning(It.Is<string>(m => m.Contains("Cannot pause")), "MonitoringService"), 
            Times.Once);
    }

    [Fact]
    public async Task StateChanged_ShouldBeRaisedOnTransitions()
    {
        // Arrange
        var stateChanges = new List<(MonitoringState Previous, MonitoringState New)>();
        _sut.StateChanged += (s, e) => stateChanges.Add((e.PreviousState, e.NewState));

        // Act
        await _sut.StartAsync();
        await Task.Delay(100);

        // Assert
        stateChanges.Should().Contain(x => x.Previous == MonitoringState.Idle && x.New == MonitoringState.Starting);
        stateChanges.Should().Contain(x => x.Previous == MonitoringState.Starting && x.New == MonitoringState.Running);
    }

    [Fact]
    public async Task StartAsync_ShouldInitializePowerShellBridgeIfNotInitialized()
    {
        // Arrange
        _mockPowerShellBridge.Setup(x => x.IsInitialized).Returns(false);

        // Act
        await _sut.StartAsync();

        // Assert
        _mockPowerShellBridge.Verify(x => x.InitializeAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    public void Dispose()
    {
        _sut.Dispose();
    }
}
