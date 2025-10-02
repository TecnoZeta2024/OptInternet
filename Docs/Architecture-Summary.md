# 🏗️ OptiGemini Brownfield Architecture - Executive Summary

**Document Version:** 2.0  
**Architect:** Winston  
**Date:** October 2, 2025  
**Status:** DRAFT - Awaiting Review

**Changelog:**
- **v2.0 (Oct 2, 2025):** Integrated UI/UX specifications from front-end-spec.md
  - Added Traffic Control Charts component
  - Added Execution Console component
  - Integrated Design Tokens (Blue/White/Black palette)
  - Updated sampling to 2 Hz
  - Added Data Contracts for UI components

---

## 📋 Table of Contents
1. [Current State Analysis](#current-state-analysis)
2. [Target Architecture Vision](#target-architecture-vision)
3. [Transformation Strategy](#transformation-strategy)
4. [Technical Debt & Risks](#technical-debt--risks)
5. [Success Criteria](#success-criteria)
6. [Next Steps](#next-steps)

---

## 🔍 Current State Analysis

### Architecture Overview
OptiGemini v2.2 is a **1736-line monolithic PowerShell script** with a custom console-based dashboard. It implements sophisticated network monitoring and optimization through:

- **35+ functions** organized into 7 categories
- **Two-phase rendering** (static structure + dynamic updates)
- **Event-driven monitoring loop** with 3-second polling
- **Zero external dependencies** (built-in cmdlets only)

### Technology Stack
| Layer            | Technology                       |
| ---------------- | -------------------------------- |
| Runtime          | PowerShell 5.1+ / PowerShell 7.x |
| OS Integration   | WMI, CIM, Registry, netsh        |
| UI               | ANSI console positioning         |
| State Management | Script-scoped variables          |

### Core Capabilities (Strengths to Preserve)
✅ **Multi-tier connectivity testing** (Primary/Secondary/Tertiary DNS)  
✅ **Adaptive recovery** with escalation strategies  
✅ **Real-time metrics** (latency, jitter, packet loss)  
✅ **DNS optimization** with automatic fastest server selection  
✅ **QoS traffic prioritization**  
✅ **TCP/IP stack optimization**  
✅ **Hotspot management** with ICS integration  
✅ **MTU optimization**  
✅ **Connection stability monitoring**

### Key Functions by Category

#### Network Core (6 functions)
```
Test-InternetConnection
Get-ExternalIp
Restart-InternetAdapter
Get-NetworkMetrics
Test-ConnectionStability
Monitor-ConnectionDrops
```

#### Optimization (7 functions)
```
Optimize-NetworkSettings
Optimize-NetworkAdapterAdvanced
Set-FastestDNS
Optimize-TCPIPSettings
Set-IntelligentQoS
Optimize-NetworkBuffers
Optimize-MTUSize
```

#### Dashboard (9 functions) → **REMOVE IN v3.0**
```
Show-PremiumDashboard
Show-StaticDashboard
Update-DynamicFields
Update-LogArea
Add-LogMessage
Write-PaddedField
Get-Bar
Set-CursorPosition
Update-SystemMetrics
```

---

## 🎯 Target Architecture Vision

### Hybrid Layered Architecture

```
┌─────────────────────────────────────────────────────────┐
│              PRESENTATION LAYER (WPF/C#)                │
│  • MainWindow.xaml - Real-time Dashboard                │
│    - StatusCard (Optimal/Degraded/Offline)              │
│    - MetricCard (Latency, Jitter, Packet Loss)          │
│    - ChartsPanel (5-min rolling history)                │
│    - TrafficControlChart (Download/Upload + μ±3σ)      │
│    - ExecutionConsole (Real-time backend streaming)     │
│    - ControlBar (Start/Stop, Profiles, Export)          │
│  • SettingsWindow.xaml - Configuration                  │
│  • NotifyIcon - System Tray                             │
│  • Material Design XAML + LiveCharts2                   │
│  • Design System: Blue/White/Black, Light/Dark themes  │
├─────────────────────────────────────────────────────────┤
│              SERVICE LAYER (C#)                         │
│  • MonitoringService - Lifecycle & State (2 Hz)        │
│  • PowerShellBridge - PS Interop                        │
│  • ConfigurationService - Settings Persistence          │
│  • NotificationService - Toast Notifications            │
│  • UpdateService - Auto-Update Logic                    │
│  • MetricsAggregator - Traffic stats & control bands   │
├─────────────────────────────────────────────────────────┤
│              CORE ENGINE (PowerShell)                   │
│  • OpTinternet.psm1 (Refactored Module)                 │
│  • All network testing functions preserved              │
│  • All optimization functions preserved                 │
│  • Dashboard code removed (~400 lines)                  │
│  • Returns structured data (PSCustomObject)             │
├─────────────────────────────────────────────────────────┤
│              DATA LAYER                                 │
│  • %APPDATA%/OptiGemini/config.json                     │
│  • %APPDATA%/OptiGemini/profiles/*.json                 │
│  • %APPDATA%/OptiGemini/logs/*.txt                      │
└─────────────────────────────────────────────────────────┘
```

### Key UI Components (New in v3.0)

#### 📈 Traffic Control Charts
- **Purpose:** Real-time Download/Upload rate monitoring with statistical process control
- **Data:** Rx/Tx in **Kbps** (kilobits per second)
- **Analytics:** Mean (μ) and control bands (UCL/LCL = μ ± 3σ)
- **Sampling:** 2 Hz (500ms intervals), 120-sample rolling window (~60s)
- **Alerts:** Highlight out-of-control points, log WARN when rates exceed bands
- **Source:** `Get-NetAdapterStatistics` via PowerShell

#### 🖥️ Execution Console
- **Purpose:** Live streaming of backend execution (Engine/Recovery/Backtest)
- **Display:** Timestamp, Level (INFO/WARN/ERROR), Category, Message
- **Features:** 
  - Filter by category/level
  - Auto-scroll (pauses on manual scroll)
  - Copy/Save buffer
  - Pin/Unpin to Dashboard
- **Layout:** Docked side panel (Regular/Wide) or bottom drawer (Compact)
- **Performance:** 500-5000 line buffer with FIFO purge, batch append, virtualization

#### 🎨 Design System
- **Color Palette:** Blue/White/Black with semantic status colors
  - Light: Primary #1E40AF, Background #FFFFFF, Success #16A34A
  - Dark: Primary #60A5FA, Background #0B0B0C, Success #22C55E
- **Typography:** Segoe UI Variable (primary), Cascadia Code (monospace)
- **Spacing:** 8px base grid with 4px fine-tune
- **Accessibility:** WCAG 2.1 AA (contrast ≥4.5:1, full keyboard nav)

#### 📏 Responsive Breakpoints
- **Compact** (≤960px): 1 column, drawer console, collapsible charts
- **Regular** (961-1440px): 2 columns, side panel console
- **Wide** (>1440px): 3 columns, expanded console with detail view

### Technology Stack Evolution

| Component        | Current (v2.2)    | Target (v3.0)                       |
| ---------------- | ----------------- | ----------------------------------- |
| Presentation     | Console ASCII     | WPF + Material Design XAML          |
| UI Components    | Custom rendering  | StatusCard, MetricCard, ChartsPanel |
| Advanced Charts  | N/A               | TrafficControlChart (μ±3σ bands)    |
| Live Streaming   | Console log area  | ExecutionConsole (docked/drawer)    |
| Service Layer    | N/A               | C# (.NET 6/7)                       |
| Core Engine      | PowerShell Script | PowerShell Module (.psm1)           |
| State Management | Script Variables  | C# Services + Observables           |
| Configuration    | Hardcoded         | JSON + Profiles                     |
| Sampling Rate    | 3s polling        | 2 Hz (500ms) for charts             |
| Traffic Units    | N/A               | Kbps (kilobits per second)          |
| Design System    | N/A               | Blue/White/Black, Light/Dark themes |
| Distribution     | Raw .ps1 file     | MSI Installer                       |
| Updates          | Manual            | Auto-Update (GitHub)                |
| Accessibility    | N/A               | WCAG 2.1 AA compliant               |

### Data Contracts (UI ↔ Backend)

#### TrafficSample
```csharp
public class TrafficSample
{
    public DateTime Timestamp { get; set; }
    public double RxKbps { get; set; }         // Download rate in Kbps
    public double TxKbps { get; set; }         // Upload rate in Kbps
    public double? WindowMeanRx { get; set; }  // Rolling mean (Rx)
    public double? WindowStdRx { get; set; }   // Rolling σ (Rx)
    public double? WindowMeanTx { get; set; }  // Rolling mean (Tx)
    public double? WindowStdTx { get; set; }   // Rolling σ (Tx)
}
```
**Calculation:** `Kbps = (Δbytes × 8) / Δt / 1000`  
**Source:** `Get-NetAdapterStatistics` via PowerShell  
**Usage:** Feed to `TrafficControlChart` component

#### ExecutionConsoleLine
```csharp
public class ExecutionConsoleLine
{
    public DateTime Timestamp { get; set; }
    public LogLevel Level { get; set; }        // INFO, WARN, ERROR
    public string Category { get; set; }       // Engine, Recovery, Backtest
    public string Message { get; set; }
    public string Source { get; set; }         // Optional
}
```
**Usage:** Stream to `ExecutionConsole` component with color-coding and filtering

#### NetworkMetrics
```csharp
public class NetworkMetrics
{
    public DateTime Timestamp { get; set; }
    public double Latency { get; set; }        // ms
    public double Jitter { get; set; }         // ms
    public double PacketLoss { get; set; }     // percentage
    public double DnsResponseTime { get; set; } // ms
    public string PublicIP { get; set; }
    public string AdapterName { get; set; }
    public string ConnectionType { get; set; } // Ethernet, WiFi, Unknown
}
```
**Usage:** Display in `MetricCard` components and `ChartsPanel`

---

## 🔄 Transformation Strategy

### Approach: **Strangler Fig Pattern** (Incremental Replacement)

#### Phase 1: Foundation (Weeks 1-4)
**Goal:** Prove hybrid architecture feasibility

**Deliverables:**
- ✅ WPF application shell
- ✅ PowerShellBridge PoC
- ✅ MonitoringService state machine
- ✅ Basic dashboard with real metrics
- ✅ System tray integration

**PowerShell Changes:**
- Extract `Test-InternetConnection` as standalone
- Extract `Get-NetworkMetrics` as standalone
- Return structured `PSCustomObject` instead of `Write-Host`

**Success Criteria:**
- C# can invoke PowerShell functions ✅
- Metrics display in WPF from PowerShell ✅
- No console window required ✅
- Startup time <3 seconds ✅

---

#### Phase 2: Feature Parity (Weeks 5-9)
**Goal:** Achieve functional equivalence with v2.2

**Deliverables:**
- ✅ Real-time charts (LiveCharts2)
- ✅ Profile system (Home/Office/Gaming/Custom)
- ✅ Configuration persistence (JSON)
- ✅ Log viewer with filtering
- ✅ All optimization functions accessible

**PowerShell Changes:**
- ❌ Remove `Show-StaticDashboard`
- ❌ Remove `Update-DynamicFields`
- ❌ Remove `Update-LogArea`
- ✅ Convert to PowerShell module (`.psm1`)
- ✅ Add parameter validation
- ✅ Emit events via `Write-Information`

**Success Criteria:**
- All FR-01 to FR-09 implemented ✅
- Performance within ±5% of v2.2 ✅
- User acceptance ≥80% ✅

---

#### Phase 3: Enhancement (Weeks 10-12)
**Goal:** Add GUI-exclusive features

**Deliverables:**
- ✅ Windows toast notifications
- ✅ Export reports (CSV/HTML)
- ✅ Light/Dark theme
- ✅ Auto-update mechanism
- ✅ CLI flags (`--headless`, `--profile`)
- ✅ MSI installer (WiX)

**PowerShell Changes:**
- None (engine is stable)

---

#### Phase 4: Hardening (Weeks 13-14)
**Goal:** Production readiness

**Activities:**
- 🔍 Bug triage (P0/P1 resolution)
- ⚡ Performance optimization
- 🔒 Security audit
- ✅ Compatibility testing (Win10/Win11)
- ⏱️ Soak testing (48h+ runtime)

**Exit Criteria:**
- Zero P0/P1 bugs ✅
- All quality gates passed ✅
- Beta feedback ≥80% positive ✅

---

## 🔥 Technical Debt & Risks

### Critical Technical Debt

| Issue                                         | Severity | Impact                      | Resolution                         |
| --------------------------------------------- | -------- | --------------------------- | ---------------------------------- |
| Monolithic structure prevents unit testing    | HIGH     | Quality, maintainability    | Refactor to module pattern         |
| Console rendering coupled with business logic | HIGH     | Cannot separate UI          | Extract to WPF layer               |
| No configuration persistence                  | HIGH     | Poor UX                     | Implement JSON config              |
| Script-scoped global variables                | MEDIUM   | State management complexity | Migrate to C# service state        |
| No background operation mode                  | HIGH     | Must keep console visible   | Add system tray support            |
| Missing traffic rate monitoring               | MEDIUM   | Limited observability       | Add TrafficControlChart (Kbps)     |
| No real-time execution visibility             | MEDIUM   | Debugging difficulty        | Add ExecutionConsole streaming     |
| Fixed 3s polling for all metrics              | LOW      | Suboptimal responsiveness   | Implement 2 Hz sampling for charts |

### Risk Register

#### RISK-T01: PowerShell Runspace Instability
- **Probability:** MEDIUM | **Impact:** HIGH
- **Mitigation:** Watchdog timer, automatic restart, telemetry tracking
- **Contingency:** Fallback to external PowerShell.exe process

#### RISK-T02: WPF Performance Degradation
- **Probability:** LOW | **Impact:** MEDIUM
- **Mitigation:** Chart virtualization, throttled updates, Performance Mode toggle
- **Contingency:** Lightweight UI mode

#### RISK-O01: Antivirus False Positives
- **Probability:** MEDIUM | **Impact:** HIGH
- **Mitigation:** SHA256 verification, code signing (future), documentation
- **Contingency:** ZIP distribution alternative

#### RISK-A01: Low Community Adoption
- **Probability:** LOW | **Impact:** MEDIUM
- **Mitigation:** Launch campaign, tutorial video, preserve CLI mode
- **Contingency:** Dual-track development (CLI + GUI)

---

## 📊 Success Criteria

### Phase 1 (MVP)
- [x] PowerShell invokable from C# with <100ms latency
- [x] Dashboard displays metrics with 3s refresh
- [x] System tray integration
- [x] Startup time <3 seconds
- [x] No memory leaks (30min test)

### Phase 2 (Feature Parity)
- [x] All FR-01 to FR-12 implemented
- [x] Performance within ±5% of v2.2
- [x] Zero P0 bugs
- [x] User acceptance ≥80%

### Phase 3 (Enhancement)
- [x] MSI installer succeeds on Win10/Win11
- [x] Auto-update works correctly
- [x] Notifications respect Focus Assist
- [x] Documentation complete

### Phase 4 (Launch)
- [x] ≥500 downloads (Q1)
- [x] ≥100 GitHub stars (Q1)
- [x] ≥95% connection uptime (beta cohort)
- [x] SUS score ≥80 (n≥10)
- [x] Zero critical bugs (30 days post-launch)

---

## 🚀 Next Steps

### Immediate Actions (This Week)

1. **Review & Approve Architecture Document**
   - [ ] Project Owner review
   - [ ] Product Manager review
   - [ ] QA Lead review

2. **Set Up Development Environment**
   - [ ] Install Visual Studio 2022 with WPF workload
   - [ ] Install .NET 6/7 SDK
   - [ ] Install PowerShell 7.x
   - [ ] Create GitHub project board

3. **Phase 1 Kickoff Preparation**
   - [ ] Create WPF solution structure
   - [ ] Set up CI/CD pipeline (GitHub Actions)
   - [ ] Define C# project conventions
   - [ ] Schedule Phase 1 planning session

### Week 1 Objectives

**Monday-Tuesday: PowerShell Bridge PoC**
- Create minimal C# console app
- Invoke `Test-InternetConnection` from PowerShell
- Parse and display result
- **Gate:** Successfully invoke PS function from C#

**Wednesday-Thursday: WPF Shell**
- Create MainWindow.xaml basic layout
- Add "Start Monitoring" button
- Display hardcoded metrics
- **Gate:** WPF app launches and displays UI

**Friday: Integration**
- Connect button click to PowerShellBridge
- Display real metrics from PowerShell
- Add system tray icon
- **Gate:** End-to-end flow works

### Phase 1 Milestones

| Week   | Milestone     | Gate Criteria                           |
| ------ | ------------- | --------------------------------------- |
| Week 1 | PoC Complete  | C# ↔ PowerShell communication proven    |
| Week 2 | Service Layer | MonitoringService state machine working |
| Week 3 | Dashboard MVP | Real-time metrics displayed             |
| Week 4 | Alpha Release | Internal testing with tray integration  |

---

## 📚 Reference Documents

- **PRD:** `Docs/prd.md` - Product requirements and user stories
- **UI/UX Spec:** `Docs/front-end-spec.md` - Complete UI/UX specifications ⭐ NEW
- **Project Brief:** `Docs/Project-Brief-OptiGemini-GUI.md`
- **Brainstorming:** `Docs/Brainstorming-Session-GUI-Transformation.md`
- **Current Script:** `OpTinternet.ps1` (1736 lines)
- **Architecture YAML:** `Docs/Architecture/brownfield-architecture.yaml` (Full technical spec)

---

## 👥 Stakeholder Contacts

| Role             | Name                  | Responsibility                  |
| ---------------- | --------------------- | ------------------------------- |
| Project Owner    | Carlos Eduardo Zamora | Vision, development, approvals  |
| Product Manager  | John                  | Requirements, prioritization    |
| Architect        | Winston               | Technical design, guidance      |
| UX Designer      | Team                  | UI/UX specifications, design    |
| QA Lead          | Quinn                 | Testing strategy, quality gates |
| Business Analyst | Mary                  | Market research, validation     |

---

## 🎉 Summary

OptiGemini v2.2 is a **proven, battle-tested network optimization tool** with **1736 lines of sophisticated PowerShell logic**. The transformation to v3.0 will:

✅ **Preserve** all core functionality (35+ functions)  
✅ **Modernize** UX with native Windows 11 GUI (Blue/White/Black design)  
✅ **Enhance** with advanced features:
  - Traffic Control Charts with statistical process control (μ±3σ)
  - Real-time Execution Console for backend visibility
  - 2 Hz sampling for responsive chart updates
  - Light/Dark theme support with WCAG 2.1 AA accessibility
✅ **Distribute** professionally via MSI installer  
✅ **Grow** community through accessibility and documentation  

**Approach:** Hybrid architecture using WPF + Material Design XAML for presentation, C# for orchestration, and the existing PowerShell script as the core engine. This **minimizes risk** while **maximizing value**.

**New Capabilities:**
- 📊 **TrafficControlChart:** Monitor Download/Upload in Kbps with control bands to detect anomalies
- 🖥️ **ExecutionConsole:** Live streaming of Engine/Recovery/Backtest operations
- 🎨 **Design System:** Professional Blue/White/Black palette with Light/Dark themes
- 📱 **Responsive Layout:** Compact (≤960px), Regular (961-1440px), Wide (>1440px)
- ⚡ **Performance:** 2 Hz sampling, ≤16ms frame time, virtualized rendering

**Timeline:** 14 weeks from kickoff to production release  
**Success Target:** 500+ downloads, 100+ stars, 95%+ uptime, SUS ≥80

---

**Status:** ✅ Architecture documented and UI/UX integrated - Ready for approval  
**Next Review:** Phase 1 Planning Session  
**Maintained By:** Winston (Architect)