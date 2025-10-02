# 📝 REQUIREMENTS ELICITATION
## OptiGemini v3.0 - Comprehensive Requirements Analysis

**Document Version:** 1.0  
**Date:** 2 de Octubre, 2025  
**Business Analyst:** Mary  
**Project:** OptiGemini Desktop Application Transformation  
**Method:** Advanced Elicitation - Structured Interview & Analysis

---

## 🎯 ELICITATION OVERVIEW

### Purpose of This Document

This document captures detailed requirements for transforming OptiGemini from a PowerShell console script into a professional Windows 11 desktop application. Requirements are organized using the **MoSCoW method** (Must have, Should have, Could have, Won't have) and prioritized across development phases.

### Elicitation Techniques Used

1. **Stakeholder Interview** (with Project Owner)
2. **Document Analysis** (existing OpTinternet.ps1 code review)
3. **Competitive Analysis** (market research)
4. **Use Case Analysis** (scenario-based requirements)
5. **Persona Development** (user-centered design)

---

## 👤 STAKEHOLDER CONTEXT

### Primary Stakeholder: Carlos Eduardo Zamora (Project Owner)

**Background:**
- Professional programmer working in real-time environments
- Located in area with chronically unstable internet connectivity
- Advanced PowerShell skills, intermediate C# knowledge
- Created OptiGemini v2.2 to solve personal pain point

**Key Motivations:**
1. Eliminate manual network troubleshooting during work hours
2. Share solution with others experiencing similar problems
3. Learn WPF/GUI development skills
4. Build community around open-source project

**Constraints:**
- Part-time development (evenings/weekends)
- Zero budget for infrastructure or licenses
- Solo developer (no team)
- Must maintain current script's effectiveness

**Success Definition:**
"A Windows app that runs in the background, keeps my connection stable without me thinking about it, and helps others with bad internet. If 500 people download it and it works for them, I'll consider it successful."

---

## 📊 REQUIREMENTS CATEGORIES

Requirements are organized into:
1. **Functional Requirements** (what the system must do)
2. **Non-Functional Requirements** (qualities the system must have)
3. **UI/UX Requirements** (interface and experience)
4. **Technical Requirements** (architecture and implementation)
5. **Deployment Requirements** (distribution and installation)

---

## 🔴 FUNCTIONAL REQUIREMENTS

### FR-001: Network Monitoring (MUST HAVE - Phase 1)

**Priority:** Critical ⭐⭐⭐⭐⭐

**Description:**
System must continuously monitor network connectivity and performance metrics.

**Detailed Requirements:**

| ID       | Requirement                              | Acceptance Criteria                                     | Priority |
| -------- | ---------------------------------------- | ------------------------------------------------------- | -------- |
| FR-001.1 | Monitor latency to primary DNS (8.8.8.8) | Update every 3 seconds, display in milliseconds         | MUST     |
| FR-001.2 | Calculate jitter (latency variance)      | Show average deviation from mean latency                | MUST     |
| FR-001.3 | Track packet loss percentage             | Count successful vs. failed ping attempts               | MUST     |
| FR-001.4 | Detect connection drops                  | Identify complete loss of connectivity within 5 seconds | MUST     |
| FR-001.5 | Measure DNS response time                | Time to resolve common domains                          | SHOULD   |
| FR-001.6 | Track network adapter status             | Detect if adapter is up/down                            | MUST     |
| FR-001.7 | Monitor uptime                           | Display total time since monitoring started             | MUST     |
| FR-001.8 | Count recovery attempts                  | Track how many times connection was recovered           | SHOULD   |

**User Stories:**
- As a remote worker, I want to see real-time latency so I know if my connection is stable
- As a user, I want to be alerted when packet loss occurs so I can understand why my connection feels slow
- As a power user, I want detailed metrics so I can diagnose specific issues

**Source:** Derived from OpTinternet.ps1 `Get-NetworkMetrics` function

---

### FR-002: Automatic Connection Recovery (MUST HAVE - Phase 1)

**Priority:** Critical ⭐⭐⭐⭐⭐

**Description:**
System must automatically detect and recover from connection failures without user intervention.

**Detailed Requirements:**

| ID        | Requirement                   | Acceptance Criteria                                 | Priority |
| --------- | ----------------------------- | --------------------------------------------------- | -------- |
| FR-002.1  | Detect connection failure     | Identify failure within 3-5 seconds                 | MUST     |
| FR-002.2  | Flush DNS cache               | Execute `ipconfig /flushdns` on failure             | MUST     |
| FR-002.3  | Restart network adapter       | Disable/enable adapter with 3-second delay          | MUST     |
| FR-002.4  | Switch to secondary DNS       | Failover to 1.1.1.1 if 8.8.8.8 fails                | MUST     |
| FR-002.5  | Switch to tertiary DNS        | Failover to OpenDNS if secondary fails              | SHOULD   |
| FR-002.6  | Reset Winsock                 | Execute `netsh winsock reset` for persistent issues | SHOULD   |
| FR-002.7  | Reset TCP/IP stack            | Execute `netsh int ip reset` as last resort         | SHOULD   |
| FR-002.8  | Adaptive recovery escalation  | Try lighter fixes first, escalate to heavier        | MUST     |
| FR-002.9  | Recovery success notification | Alert user when connection is restored              | SHOULD   |
| FR-002.10 | Recovery failure alert        | Notify user if all recovery attempts fail           | MUST     |

**Recovery Strategy Flow:**
```
Connection Lost
    ↓
Level 1: Flush DNS cache (3s wait)
    ↓ (if still failing)
Level 2: Switch DNS server (5s wait)
    ↓ (if still failing)
Level 3: Restart adapter (10s wait)
    ↓ (if still failing)
Level 4: Reset Winsock + TCP/IP (15s wait)
    ↓ (if still failing)
Level 5: Alert user for manual intervention
```

**User Stories:**
- As a remote worker, I want my connection to recover automatically so I don't lose my place during calls
- As a gamer, I want fast recovery so I can reconnect to my game quickly
- As a non-technical user, I don't want to manually troubleshoot network issues

**Source:** Derived from OpTinternet.ps1 `Invoke-AdaptiveRecovery` and related functions

---

### FR-003: DNS Optimization (MUST HAVE - Phase 1)

**Priority:** High ⭐⭐⭐⭐

**Description:**
System must automatically select and configure the fastest DNS server.

**Detailed Requirements:**

| ID       | Requirement               | Acceptance Criteria                   | Priority |
| -------- | ------------------------- | ------------------------------------- | -------- |
| FR-003.1 | Test multiple DNS servers | Ping 8.8.8.8, 1.1.1.1, 208.67.222.222 | MUST     |
| FR-003.2 | Measure DNS response time | Record time for each server           | MUST     |
| FR-003.3 | Select fastest server     | Choose server with lowest latency     | MUST     |
| FR-003.4 | Configure system DNS      | Apply selected DNS to active adapter  | MUST     |
| FR-003.5 | Periodic re-optimization  | Re-test DNS servers every 24 hours    | SHOULD   |
| FR-003.6 | Custom DNS support        | Allow user to add custom DNS servers  | SHOULD   |
| FR-003.7 | Display current DNS       | Show which DNS is currently in use    | MUST     |

**User Stories:**
- As a user, I want the fastest DNS configured so my browsing is responsive
- As a power user, I want to add my own DNS servers to the test pool

**Source:** Derived from OpTinternet.ps1 `Set-FastestDNS` function

---

### FR-004: Quality of Service (QoS) Management (SHOULD HAVE - Phase 2)

**Priority:** Medium ⭐⭐⭐

**Description:**
System should prioritize critical network traffic for better performance.

**Detailed Requirements:**

| ID       | Requirement                     | Acceptance Criteria                                 | Priority |
| -------- | ------------------------------- | --------------------------------------------------- | -------- |
| FR-004.1 | Create high-priority policies   | Set DSCP 46 for gaming/VOIP apps                    | SHOULD   |
| FR-004.2 | Create medium-priority policies | Set DSCP 34 for streaming apps                      | SHOULD   |
| FR-004.3 | Configurable app list           | Allow users to specify which apps to prioritize     | SHOULD   |
| FR-004.4 | Enable/disable QoS              | Toggle QoS on/off from UI                           | SHOULD   |
| FR-004.5 | Pre-configured profiles         | Include common apps (Zoom, Discord, Valorant, etc.) | COULD    |

**User Stories:**
- As a gamer, I want my game traffic prioritized so I have lower ping
- As a remote worker, I want my video calls prioritized over background downloads

**Source:** Derived from OpTinternet.ps1 `Set-IntelligentQoS` function

---

### FR-005: TCP/IP Optimization (SHOULD HAVE - Phase 1)

**Priority:** Medium ⭐⭐⭐

**Description:**
System should apply TCP/IP stack optimizations for improved network performance.

**Detailed Requirements:**

| ID       | Requirement              | Acceptance Criteria                      | Priority |
| -------- | ------------------------ | ---------------------------------------- | -------- |
| FR-005.1 | Configure TCP autotuning | Set to "normal" level                    | SHOULD   |
| FR-005.2 | Enable Chimney offload   | Enable if supported by adapter           | SHOULD   |
| FR-005.3 | Enable RSS               | Receive Side Scaling for multi-core      | SHOULD   |
| FR-005.4 | Configure window scaling | Enable for better throughput             | SHOULD   |
| FR-005.5 | Set initial RTO          | Configure initial retransmission timeout | SHOULD   |
| FR-005.6 | Backup current settings  | Save before applying changes             | MUST     |
| FR-005.7 | Restore on uninstall     | Revert to original settings when removed | MUST     |

**User Stories:**
- As a user, I want optimized TCP settings so downloads are faster
- As a cautious user, I want my original settings backed up so I can revert if needed

**Source:** Derived from OpTinternet.ps1 `Optimize-TCPIPSettings` function

---

### FR-006: Hotspot Management (COULD HAVE - Phase 2)

**Priority:** Low ⭐⭐

**Description:**
System could manage Windows hosted network (WiFi hotspot) functionality.

**Detailed Requirements:**

| ID       | Requirement               | Acceptance Criteria                      | Priority        |
| -------- | ------------------------- | ---------------------------------------- | --------------- |
| FR-006.1 | Configure hotspot         | Set SSID and password                    | COULD           |
| FR-006.2 | Start/stop hotspot        | Control hosted network                   | COULD           |
| FR-006.3 | Share internet connection | Enable ICS (Internet Connection Sharing) | COULD           |
| FR-006.4 | Display hotspot status    | Show if active/inactive                  | COULD           |
| FR-006.5 | Auto-start option         | Optionally start hotspot with app        | WON'T (not MVP) |

**User Stories:**
- As a user, I want to share my stabilized connection with other devices

**Source:** Derived from OpTinternet.ps1 `Start-Hotspot` function

**Note:** Lower priority as it's tangential to core connection stability mission

---

### FR-007: Logging & History (MUST HAVE - Phase 1)

**Priority:** High ⭐⭐⭐⭐

**Description:**
System must maintain detailed logs of all activities and metrics.

**Detailed Requirements:**

| ID       | Requirement         | Acceptance Criteria              | Priority |
| -------- | ------------------- | -------------------------------- | -------- |
| FR-007.1 | Log all events      | Timestamp, level, message format | MUST     |
| FR-007.2 | Log levels          | SYSTEM, INFO, WARN, ERROR levels | MUST     |
| FR-007.3 | Rotating log files  | New file daily, keep 30 days     | SHOULD   |
| FR-007.4 | Performance history | Store metrics over time          | SHOULD   |
| FR-007.5 | Export logs         | Allow user to export/view logs   | SHOULD   |
| FR-007.6 | Search/filter logs  | Find specific events             | COULD    |
| FR-007.7 | Log compression     | Compress old logs to save space  | COULD    |

**User Stories:**
- As a user, I want to see what actions were taken so I can understand why my connection recovered
- As a support helper, I want to export logs to diagnose issues

**Source:** Derived from OpTinternet.ps1 `Write-Log` function and `$script:performanceHistory`

---

### FR-008: Configuration Profiles (SHOULD HAVE - Phase 2)

**Priority:** Medium ⭐⭐⭐

**Description:**
System should support multiple configuration profiles for different scenarios.

**Detailed Requirements:**

| ID       | Requirement           | Acceptance Criteria                           | Priority |
| -------- | --------------------- | --------------------------------------------- | -------- |
| FR-008.1 | Create profiles       | Define named configuration sets               | SHOULD   |
| FR-008.2 | Switch profiles       | Quick toggle between profiles                 | SHOULD   |
| FR-008.3 | Pre-defined profiles  | Include Home, Office, Gaming, Battery presets | SHOULD   |
| FR-008.4 | Custom profiles       | Allow users to create custom profiles         | SHOULD   |
| FR-008.5 | Profile persistence   | Save/load profiles across sessions            | SHOULD   |
| FR-008.6 | Profile export/import | Share profiles with other users               | COULD    |

**Profiles:**

**Home Profile (Default):**
- Monitoring interval: 3 seconds
- Recovery: Aggressive
- All optimizations: Enabled
- QoS: Disabled

**Office Profile:**
- Monitoring interval: 10 seconds
- Recovery: Moderate (avoid interfering with corporate VPN)
- TCP optimizations: Enabled
- QoS: Teams/Zoom priority

**Gaming Profile:**
- Monitoring interval: 3 seconds
- Recovery: Aggressive
- QoS: Gaming apps prioritized
- Latency threshold: 100ms (stricter)

**Battery/Portable Profile:**
- Monitoring interval: 30 seconds
- Recovery: Light
- Minimal optimizations
- Power-saving mode

**User Stories:**
- As a user, I want to switch to "Gaming mode" when I play so my connection is optimized for low latency
- As a remote worker, I want an "Office" profile that doesn't interfere with my company VPN

---

### FR-009: Reporting & Analytics (SHOULD HAVE - Phase 2)

**Priority:** Medium ⭐⭐⭐

**Description:**
System should provide analytical insights and exportable reports.

**Detailed Requirements:**

| ID       | Requirement         | Acceptance Criteria                    | Priority        |
| -------- | ------------------- | -------------------------------------- | --------------- |
| FR-009.1 | Uptime statistics   | Calculate total uptime percentage      | SHOULD          |
| FR-009.2 | Recovery statistics | Show success/failure rates             | SHOULD          |
| FR-009.3 | Performance trends  | Graph latency over time                | SHOULD          |
| FR-009.4 | Export to CSV       | Generate CSV report of metrics         | SHOULD          |
| FR-009.5 | Export to HTML      | Generate visual HTML report            | COULD           |
| FR-009.6 | Export to PDF       | Generate PDF report (for ISP evidence) | COULD           |
| FR-009.7 | Scheduled reports   | Auto-generate weekly/monthly reports   | WON'T (not MVP) |

**User Stories:**
- As a user, I want to see my weekly uptime so I know if my connection improved
- As a user, I want to export a report to show my ISP how bad the connection is

---

### FR-010: Notifications (SHOULD HAVE - Phase 1)

**Priority:** High ⭐⭐⭐⭐

**Description:**
System should notify users of important events via Windows toast notifications.

**Detailed Requirements:**

| ID       | Requirement           | Acceptance Criteria                          | Priority |
| -------- | --------------------- | -------------------------------------------- | -------- |
| FR-010.1 | Connection restored   | Notify when recovery succeeds                | SHOULD   |
| FR-010.2 | Connection lost       | Alert when connection is lost                | SHOULD   |
| FR-010.3 | High latency warning  | Alert when latency exceeds threshold         | COULD    |
| FR-010.4 | Critical failure      | Notify when all recovery attempts fail       | MUST     |
| FR-010.5 | Notification settings | Allow user to configure verbosity            | SHOULD   |
| FR-010.6 | Sound toggle          | Enable/disable notification sounds           | SHOULD   |
| FR-010.7 | Do Not Disturb mode   | Suppress notifications during specific hours | COULD    |

**User Stories:**
- As a user, I want to be notified when my connection recovers so I know it's safe to continue work
- As a user during meetings, I want to disable notifications so they don't disturb me

---

## 🎨 UI/UX REQUIREMENTS

### UX-001: Main Dashboard Window (MUST HAVE - Phase 1)

**Priority:** Critical ⭐⭐⭐⭐⭐

**Description:**
Primary application window with real-time network metrics and controls.

**Detailed Requirements:**

| ID        | Requirement              | Acceptance Criteria                          | Priority |
| --------- | ------------------------ | -------------------------------------------- | -------- |
| UX-001.1  | Real-time metric display | Update every 1-3 seconds                     | MUST     |
| UX-001.2  | Status indicator         | Large, prominent connection health indicator | MUST     |
| UX-001.3  | Start/Stop buttons       | Clear control buttons                        | MUST     |
| UX-001.4  | Latency chart            | Line graph showing latency over time         | SHOULD   |
| UX-001.5  | Jitter visualization     | Area chart or bars                           | SHOULD   |
| UX-001.6  | Packet loss indicator    | Percentage with visual bar                   | MUST     |
| UX-001.7  | Current DNS display      | Show active DNS server                       | SHOULD   |
| UX-001.8  | Uptime counter           | Display time since monitoring started        | SHOULD   |
| UX-001.9  | Recovery count           | Number of successful recoveries              | SHOULD   |
| UX-001.10 | Minimize to tray         | Button to minimize to system tray            | MUST     |

**Layout Sketch:**
```
┌─────────────────────────────────────────────────────────┐
│  OptiGemini                                    [_][□][X] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│         ┌───────────────────────────────┐              │
│         │  ●  Connection Status         │              │
│         │     [  STABLE - 45ms  ]       │              │
│         └───────────────────────────────┘              │
│                                                         │
│  ┌───────────────────┬───────────────────────────────┐ │
│  │ Latency: 45ms    │ │ Jitter: 12ms                │ │
│  │ [████████░░]     │ │ [████░░░░]                  │ │
│  ├──────────────────┤ ├─────────────────────────────┤ │
│  │ Packet Loss: 0.2%│ │ DNS: 8.8.8.8 (Google)      │ │
│  │ [█░░░░░░░░░░]    │ │ Uptime: 5h 23m              │ │
│  └──────────────────┴ └──────────────────────────────┘ │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │        📊 Latency Graph (5 min)                 │  │
│  │                                                  │  │
│  │     [line chart showing latency over time]      │  │
│  │                                                  │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
│     [▶ Start]  [⏸ Pause]  [🔄 Force Recovery]        │
│                                                         │
│  Profile: [Home ▼]       [⚙ Settings]  [📊 Logs]     │
└─────────────────────────────────────────────────────────┘
```

**User Stories:**
- As a user, I want to see at a glance if my connection is stable
- As a visual learner, I want graphs to understand performance trends

---

### UX-002: System Tray Integration (MUST HAVE - Phase 1)

**Priority:** Critical ⭐⭐⭐⭐⭐

**Description:**
Application runs in Windows system tray with quick access menu.

**Detailed Requirements:**

| ID       | Requirement           | Acceptance Criteria                                          | Priority |
| -------- | --------------------- | ------------------------------------------------------------ | -------- |
| UX-002.1 | Tray icon             | Icon changes based on connection status                      | MUST     |
| UX-002.2 | Icon states           | Green (good), Yellow (degraded), Red (failed), Gray (paused) | MUST     |
| UX-002.3 | Tooltip               | Hover shows quick stats (uptime, latency)                    | SHOULD   |
| UX-002.4 | Context menu          | Right-click shows action menu                                | MUST     |
| UX-002.5 | Show/Hide window      | Toggle main window visibility                                | MUST     |
| UX-002.6 | Quick actions         | Force recovery, pause, exit from menu                        | SHOULD   |
| UX-002.7 | Minimize on close     | Clicking X minimizes to tray (doesn't exit)                  | SHOULD   |
| UX-002.8 | Balloon notifications | Use tray for notifications                                   | SHOULD   |

**Context Menu:**
```
┌─────────────────────────────┐
│ ⚫ OptiGemini - Stable      │
├─────────────────────────────┤
│ ▶  Resume Monitoring        │
│ 🔄 Force Recovery           │
│ 📊 Show Dashboard           │
│ ⚙  Settings                 │
│ 📄 View Logs                │
├─────────────────────────────┤
│ ❌ Exit                     │
└─────────────────────────────┘
```

**User Stories:**
- As a user, I want the app to run in the background without cluttering my taskbar
- As a user, I want to quickly see connection status from the tray icon

---

### UX-003: Settings Window (SHOULD HAVE - Phase 1)

**Priority:** High ⭐⭐⭐⭐

**Description:**
Configuration interface for all user-adjustable settings.

**Detailed Requirements:**

| ID        | Requirement           | Acceptance Criteria                  | Priority |
| --------- | --------------------- | ------------------------------------ | -------- |
| UX-003.1  | Monitoring settings   | Configure check interval, thresholds | MUST     |
| UX-003.2  | DNS settings          | Add/remove custom DNS servers        | SHOULD   |
| UX-003.3  | Recovery settings     | Configure aggressiveness level       | SHOULD   |
| UX-003.4  | QoS settings          | Manage prioritized applications      | SHOULD   |
| UX-003.5  | Hotspot settings      | Configure SSID, password             | COULD    |
| UX-003.6  | Notification settings | Configure alert levels               | SHOULD   |
| UX-003.7  | Appearance settings   | Theme (light/dark), window size      | SHOULD   |
| UX-003.8  | Advanced settings     | TCP/IP tweaks, expert options        | COULD    |
| UX-003.9  | Reset to defaults     | Button to restore default settings   | SHOULD   |
| UX-003.10 | Save/Cancel           | Apply or discard changes             | MUST     |

**User Stories:**
- As a power user, I want to fine-tune monitoring intervals for my specific needs
- As a cautious user, I want to reset to defaults if I break something

---

### UX-004: Log Viewer Window (SHOULD HAVE - Phase 1)

**Priority:** Medium ⭐⭐⭐

**Description:**
Interface for viewing, searching, and exporting logs.

**Detailed Requirements:**

| ID       | Requirement     | Acceptance Criteria                             | Priority |
| -------- | --------------- | ----------------------------------------------- | -------- |
| UX-004.1 | Log display     | Show recent logs with timestamp, level, message | SHOULD   |
| UX-004.2 | Auto-scroll     | Optionally auto-scroll to newest entries        | SHOULD   |
| UX-004.3 | Level filtering | Filter by INFO, WARN, ERROR, etc.               | SHOULD   |
| UX-004.4 | Search function | Find specific text in logs                      | COULD    |
| UX-004.5 | Copy logs       | Copy selected entries to clipboard              | SHOULD   |
| UX-004.6 | Export logs     | Save logs to file                               | SHOULD   |
| UX-004.7 | Clear logs      | Option to clear log history                     | COULD    |

**User Stories:**
- As a troubleshooter, I want to see what happened before a connection failure
- As a user seeking support, I want to copy logs to share with helpers

---

### UX-005: First-Run Experience (SHOULD HAVE - Phase 1)

**Priority:** Medium ⭐⭐⭐

**Description:**
Onboarding flow for new users.

**Detailed Requirements:**

| ID       | Requirement            | Acceptance Criteria                    | Priority |
| -------- | ---------------------- | -------------------------------------- | -------- |
| UX-005.1 | Welcome screen         | Explain what OptiGemini does           | SHOULD   |
| UX-005.2 | Admin check            | Warn if not running as administrator   | MUST     |
| UX-005.3 | Profile selection      | Ask user to choose initial profile     | SHOULD   |
| UX-005.4 | Quick tour             | Optional UI tour highlighting features | COULD    |
| UX-005.5 | Start minimized option | Ask if should start in tray on boot    | SHOULD   |

**User Stories:**
- As a new user, I want to understand what the app does before it starts making changes
- As a non-technical user, I need guidance on which profile to use

---

### UX-006: Visual Design Standards (SHOULD HAVE - Phase 1)

**Priority:** High ⭐⭐⭐⭐

**Description:**
Application should follow modern Windows 11 design principles.

**Detailed Requirements:**

| ID       | Requirement           | Acceptance Criteria                   | Priority |
| -------- | --------------------- | ------------------------------------- | -------- |
| UX-006.1 | Windows 11 aesthetic  | Rounded corners, modern controls      | SHOULD   |
| UX-006.2 | Material Design icons | Use consistent icon set               | SHOULD   |
| UX-006.3 | Color scheme          | Follow Windows accent color           | COULD    |
| UX-006.4 | Light theme           | Clean, accessible light theme         | MUST     |
| UX-006.5 | Dark theme            | Optional dark theme                   | SHOULD   |
| UX-006.6 | Responsive layout     | Adapt to window resize                | SHOULD   |
| UX-006.7 | Accessibility         | WCAG 2.1 AA compliance where possible | SHOULD   |
| UX-006.8 | Font consistency      | Use Segoe UI (Windows default)        | MUST     |

**User Stories:**
- As a user, I want the app to look modern and fit with Windows 11
- As a dark mode user, I want a dark theme option

---

## ⚙️ NON-FUNCTIONAL REQUIREMENTS

### NFR-001: Performance (MUST HAVE)

**Priority:** Critical ⭐⭐⭐⭐⭐

| ID        | Requirement            | Measurement       | Target              | Priority |
| --------- | ---------------------- | ----------------- | ------------------- | -------- |
| NFR-001.1 | CPU usage (monitoring) | Task Manager      | <5% average         | MUST     |
| NFR-001.2 | Memory footprint       | Task Manager      | <100MB              | MUST     |
| NFR-001.3 | Startup time           | Stopwatch         | <3 seconds          | SHOULD   |
| NFR-001.4 | UI responsiveness      | User testing      | No lag/freeze       | MUST     |
| NFR-001.5 | Network overhead       | Bandwidth monitor | <10KB/s             | MUST     |
| NFR-001.6 | Recovery time          | Automated testing | <30 seconds average | SHOULD   |

**Rationale:** App must be lightweight since it runs continuously in background.

---

### NFR-002: Reliability (MUST HAVE)

**Priority:** Critical ⭐⭐⭐⭐⭐

| ID        | Requirement           | Measurement     | Target                                | Priority |
| --------- | --------------------- | --------------- | ------------------------------------- | -------- |
| NFR-002.1 | Uptime                | Telemetry       | >99% (24/7 operation)                 | MUST     |
| NFR-002.2 | Recovery success rate | Logging         | >90%                                  | SHOULD   |
| NFR-002.3 | Crash frequency       | Error reporting | <1 per 1000 hours                     | MUST     |
| NFR-002.4 | Data loss prevention  | Testing         | No config/log corruption              | MUST     |
| NFR-002.5 | Graceful degradation  | Testing         | Continue monitoring if recovery fails | SHOULD   |

**Rationale:** Users depend on this for critical work connections.

---

### NFR-003: Security (MUST HAVE)

**Priority:** High ⭐⭐⭐⭐

| ID        | Requirement          | Measurement      | Target                                | Priority |
| --------- | -------------------- | ---------------- | ------------------------------------- | -------- |
| NFR-003.1 | Admin privileges     | Manifest         | Require elevation                     | MUST     |
| NFR-003.2 | No telemetry         | Code review      | Zero data sent to external servers    | MUST     |
| NFR-003.3 | Local-only operation | Network analysis | No outbound except DNS/ping           | MUST     |
| NFR-003.4 | Password encryption  | DPAPI            | Hotspot password encrypted at rest    | SHOULD   |
| NFR-003.5 | Code signing         | Certificate      | Signed executable (optional, $100/yr) | COULD    |
| NFR-003.6 | Update security      | HTTPS            | Updates over HTTPS only               | SHOULD   |

**Rationale:** Network tools require trust; privacy is paramount for open-source.

---

### NFR-004: Compatibility (MUST HAVE)

**Priority:** High ⭐⭐⭐⭐

| ID        | Requirement           | Measurement   | Target                          | Priority |
| --------- | --------------------- | ------------- | ------------------------------- | -------- |
| NFR-004.1 | Windows 10 support    | Testing       | 21H2 and later                  | MUST     |
| NFR-004.2 | Windows 11 support    | Testing       | All versions                    | MUST     |
| NFR-004.3 | .NET version          | Documentation | .NET 6 or later                 | MUST     |
| NFR-004.4 | PowerShell version    | Testing       | PowerShell 5.1 (Windows) or 7.x | MUST     |
| NFR-004.5 | Network adapter types | Testing       | WiFi, Ethernet, USB             | SHOULD   |
| NFR-004.6 | Screen resolution     | Testing       | 1920x1080 minimum               | SHOULD   |
| NFR-004.7 | Multi-monitor         | Testing       | Support multiple displays       | COULD    |

**Rationale:** Must work on common Windows configurations.

---

### NFR-005: Maintainability (SHOULD HAVE)

**Priority:** Medium ⭐⭐⭐

| ID        | Requirement          | Measurement         | Target                           | Priority |
| --------- | -------------------- | ------------------- | -------------------------------- | -------- |
| NFR-005.1 | Code documentation   | Code review         | All public methods documented    | SHOULD   |
| NFR-005.2 | Modular architecture | Architecture review | Clear separation of concerns     | SHOULD   |
| NFR-005.3 | Error handling       | Code review         | All exceptions caught and logged | MUST     |
| NFR-005.4 | Logging coverage     | Code review         | All major operations logged      | SHOULD   |
| NFR-005.5 | Unit test coverage   | Testing             | >50% code coverage               | COULD    |

**Rationale:** Solo developer needs maintainable, understandable code for future work.

---

### NFR-006: Usability (MUST HAVE)

**Priority:** High ⭐⭐⭐⭐

| ID        | Requirement              | Measurement  | Target                                 | Priority |
| --------- | ------------------------ | ------------ | -------------------------------------- | -------- |
| NFR-006.1 | Installation simplicity  | User testing | <5 clicks to install                   | MUST     |
| NFR-006.2 | Configuration simplicity | User testing | Works with defaults for 80% users      | SHOULD   |
| NFR-006.3 | Learning curve           | User testing | <5 minutes to understand basics        | SHOULD   |
| NFR-006.4 | Error message clarity    | Review       | Plain language, actionable             | SHOULD   |
| NFR-006.5 | Help accessibility       | UI review    | Help links accessible from all screens | SHOULD   |

**Rationale:** Target audience includes non-technical users.

---

### NFR-007: Internationalization (WON'T HAVE - Out of Scope)

**Priority:** None (Deferred)

- Application will be English-only for v3.0
- Localization can be added in future versions if community contributes translations
- Code should be structured to allow future i18n

**Rationale:** Limited resources; English is sufficient for initial release.

---

## 🛠️ TECHNICAL REQUIREMENTS

### TR-001: Architecture (MUST HAVE)

**Priority:** Critical ⭐⭐⭐⭐⭐

**Selected Architecture:** WPF Frontend + PowerShell Core Backend

**Detailed Technical Stack:**

| Component                | Technology                   | Version  | Justification                               |
| ------------------------ | ---------------------------- | -------- | ------------------------------------------- |
| **GUI Framework**        | WPF                          | .NET 6/7 | Mature, native Windows, extensive resources |
| **Programming Language** | C#                           | 10.0+    | WPF standard, type-safe, modern             |
| **UI Library**           | Material Design in XAML      | Latest   | Modern appearance, components               |
| **Charts**               | LiveCharts2                  | 2.0+     | Real-time capable, WPF compatible           |
| **Backend Engine**       | PowerShell                   | 7.x      | Reuse existing 1736 lines                   |
| **PS Integration**       | System.Management.Automation | Latest   | Official C#/PS bridge                       |
| **Configuration**        | Newtonsoft.Json              | 13.0+    | JSON serialization                          |
| **Logging**              | Serilog (optional)           | Latest   | Structured logging                          |
| **Testing**              | xUnit                        | Latest   | Unit testing framework                      |

**Architecture Diagram:**
```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                      │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │ MainWindow │  │ Settings   │  │ LogViewer  │           │
│  │ (XAML)     │  │ Window     │  │ Window     │           │
│  └────────────┘  └────────────┘  └────────────┘           │
│         │                │                │                 │
│         └────────────────┴────────────────┘                 │
│                         │                                    │
│                         ▼                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              VIEW MODEL LAYER (MVVM)                 │  │
│  │  ┌──────────────┐    ┌──────────────────────────┐   │  │
│  │  │ MainViewModel│────│ MonitoringService        │   │  │
│  │  └──────────────┘    │ ConfigService            │   │  │
│  │                      │ NotificationService       │   │  │
│  │                      └──────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│                         │                                    │
│                         ▼                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           BUSINESS LOGIC BRIDGE                      │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  PowerShellBridge.cs                         │   │  │
│  │  │  - ExecuteScript(string script)              │   │  │
│  │  │  - ExecuteFunction(string func, params)      │   │  │
│  │  │  - GetVariable(string name)                  │   │  │
│  │  │  - OnOutputReceived event                    │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│                         │                                    │
│                         ▼                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              POWERSHELL CORE ENGINE                  │  │
│  │                                                      │  │
│  │  OpTinternet.ps1 (1736 lines of battle-tested code) │  │
│  │  - Test-InternetConnection                           │  │
│  │  - Restart-InternetAdapter                           │  │
│  │  - Set-FastestDNS                                    │  │
│  │  - Invoke-AdaptiveRecovery                           │  │
│  │  - Get-NetworkMetrics                                │  │
│  │  - Optimize-TCPIPSettings                            │  │
│  │  - Set-IntelligentQoS                                │  │
│  └──────────────────────────────────────────────────────┘  │
│                         │                                    │
│                         ▼                                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   DATA LAYER                         │  │
│  │  - config.json (user settings)                       │  │
│  │  - profiles.json (connection profiles)               │  │
│  │  - OptiGemini_log_YYYY-MM-DD.txt (logs)             │  │
│  │  - performance_history.db (SQLite - optional)        │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

### TR-002: PowerShell Integration Strategy (MUST HAVE)

**Priority:** Critical ⭐⭐⭐⭐⭐

**Implementation Approach:**

```csharp
// PowerShellBridge.cs - Core integration class
public class PowerShellBridge : IDisposable
{
    private PowerShell _ps;
    private Runspace _runspace;
    
    public PowerShellBridge()
    {
        // Create runspace for better performance
        _runspace = RunspaceFactory.CreateRunspace();
        _runspace.Open();
        _ps = PowerShell.Create();
        _ps.Runspace = _runspace;
        
        // Load OpTinternet.ps1
        string scriptPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "OpTinternet.ps1");
        _ps.AddScript($". '{scriptPath}'");
        _ps.Invoke();
        _ps.Commands.Clear();
    }
    
    public async Task<bool> TestInternetConnectionAsync(string hostAddress)
    {
        return await Task.Run(() =>
        {
            _ps.AddCommand("Test-InternetConnection")
               .AddParameter("HostAddress", hostAddress);
            
            var results = _ps.Invoke();
            _ps.Commands.Clear();
            
            return results.Any() && (bool)results[0].BaseObject;
        });
    }
    
    // Additional methods for other PS functions...
}
```

**Key Considerations:**
- Use async/await to prevent UI blocking
- Implement proper error handling for PS exceptions
- Use runspace pooling for concurrent operations (if needed)
- Parse PS output objects correctly

---

### TR-003: Data Persistence (SHOULD HAVE)

**Priority:** High ⭐⭐⭐⭐

**Configuration Storage:**

**config.json structure:**
```json
{
  "version": "3.0.0",
  "general": {
    "startMinimized": false,
    "startWithWindows": false,
    "checkInterval": 3,
    "currentProfile": "Home"
  },
  "monitoring": {
    "primaryDNS": "8.8.8.8",
    "secondaryDNS": "1.1.1.1",
    "tertiaryDNS": "208.67.222.222",
    "customDNS": [],
    "latencyThreshold": 150,
    "jitterThreshold": 30,
    "packetLossThreshold": 5
  },
  "recovery": {
    "aggressiveness": "high",
    "maxRetries": 5,
    "retryDelay": 1
  },
  "qos": {
    "enabled": false,
    "highPriorityApps": ["valorant.exe", "zoom.exe"],
    "mediumPriorityApps": ["netflix.exe"]
  },
  "hotspot": {
    "ssid": "OptiGemini_5G",
    "password": "encrypted_base64_string",
    "autoStart": false
  },
  "ui": {
    "theme": "light",
    "windowSize": {"width": 800, "height": 600},
    "showCharts": true
  },
  "notifications": {
    "enabled": true,
    "verbosity": "normal",
    "soundEnabled": true
  }
}
```

**Location:** `%APPDATA%\OptiGemini\config.json`

---

### TR-004: Error Handling Strategy (MUST HAVE)

**Priority:** High ⭐⭐⭐⭐

**Global Exception Handling:**

```csharp
// In App.xaml.cs
private void Application_DispatcherUnhandledException(object sender, 
    DispatcherUnhandledExceptionEventArgs e)
{
    Logger.Error($"Unhandled exception: {e.Exception}");
    
    MessageBox.Show(
        "An unexpected error occurred. The error has been logged.\n\n" +
        $"Error: {e.Exception.Message}\n\n" +
        "Please check logs or report this issue on GitHub.",
        "OptiGemini Error",
        MessageBoxButton.OK,
        MessageBoxImage.Error
    );
    
    e.Handled = true; // Prevent crash
}
```

**PowerShell Exception Handling:**

```csharp
try
{
    var result = await _powerShellBridge.RestartAdapterAsync();
}
catch (RuntimeException psException)
{
    Logger.Error($"PowerShell error: {psException.Message}");
    NotificationService.ShowError("Network adapter restart failed. Try manual restart.");
}
catch (Exception ex)
{
    Logger.Error($"Unexpected error during adapter restart: {ex}");
    NotificationService.ShowError("An unexpected error occurred.");
}
```

---

### TR-005: Logging Strategy (MUST HAVE)

**Priority:** High ⭐⭐⭐⭐

**Logging Levels:**
- **DEBUG**: Development/troubleshooting only (not in release)
- **INFO**: Normal operations (monitoring started, DNS changed)
- **WARN**: Non-critical issues (high latency, slow DNS)
- **ERROR**: Recoverable errors (recovery failed, setting not saved)
- **FATAL**: Critical errors (app cannot continue)

**Log Format:**
```
[2025-10-02 14:23:45.123] [INFO] Monitoring started with Home profile
[2025-10-02 14:24:12.456] [WARN] Latency high: 180ms (threshold: 150ms)
[2025-10-02 14:24:15.789] [INFO] DNS switched from 8.8.8.8 to 1.1.1.1
[2025-10-02 14:25:30.012] [ERROR] Failed to restart adapter: Access denied
```

**Log Rotation:**
- New file daily: `OptiGemini_log_2025-10-02.txt`
- Keep 30 days of logs
- Compress logs older than 7 days (optional)
- Maximum file size: 10MB before forcing rotation

---

## 📦 DEPLOYMENT REQUIREMENTS

### DR-001: Installation (MUST HAVE - Phase 3)

**Priority:** High ⭐⭐⭐⭐

| ID       | Requirement         | Implementation                | Priority |
| -------- | ------------------- | ----------------------------- | -------- |
| DR-001.1 | MSI Installer       | WiX Toolset 4.x               | MUST     |
| DR-001.2 | Portable version    | ZIP with bundled .NET         | SHOULD   |
| DR-001.3 | Silent install      | MSI with /quiet parameter     | COULD    |
| DR-001.4 | Install location    | Program Files\OptiGemini      | MUST     |
| DR-001.5 | Start Menu shortcut | Create shortcut               | MUST     |
| DR-001.6 | Desktop shortcut    | Optional during install       | SHOULD   |
| DR-001.7 | Uninstaller         | Windows Add/Remove Programs   | MUST     |
| DR-001.8 | Clean uninstall     | Remove all files and settings | MUST     |

---

### DR-002: Distribution (SHOULD HAVE - Phase 3)

**Priority:** High ⭐⭐⭐⭐

| ID       | Requirement          | Implementation                | Priority |
| -------- | -------------------- | ----------------------------- | -------- |
| DR-002.1 | GitHub Releases      | Primary distribution channel  | MUST     |
| DR-002.2 | WinGet manifest      | Microsoft package manager     | SHOULD   |
| DR-002.3 | Chocolatey package   | Community repository          | COULD    |
| DR-002.4 | Direct download link | Website/README link           | MUST     |
| DR-002.5 | Changelog            | Detailed release notes        | MUST     |
| DR-002.6 | Checksums            | SHA-256 hash for verification | SHOULD   |

---

### DR-003: Auto-Update (SHOULD HAVE - Phase 3)

**Priority:** Medium ⭐⭐⭐

| ID       | Requirement         | Implementation                   | Priority        |
| -------- | ------------------- | -------------------------------- | --------------- |
| DR-003.1 | Update check        | Query GitHub Releases API        | SHOULD          |
| DR-003.2 | Update notification | Alert user when update available | SHOULD          |
| DR-003.3 | Auto-download       | Download update in background    | COULD           |
| DR-003.4 | Install on restart  | Apply update on next launch      | COULD           |
| DR-003.5 | Update settings     | Allow disable auto-check         | SHOULD          |
| DR-003.6 | Rollback capability | Revert to previous version       | WON'T (not MVP) |

---

## 📋 REQUIREMENTS TRACEABILITY MATRIX

### Phase 1 (MVP) - Weeks 1-4

| Req ID  | Requirement         | Priority | Status        |
| ------- | ------------------- | -------- | ------------- |
| FR-001  | Network Monitoring  | ⭐⭐⭐⭐⭐    | ✅ Must Have   |
| FR-002  | Auto Recovery       | ⭐⭐⭐⭐⭐    | ✅ Must Have   |
| FR-003  | DNS Optimization    | ⭐⭐⭐⭐     | ✅ Must Have   |
| FR-005  | TCP/IP Optimization | ⭐⭐⭐      | ✅ Should Have |
| FR-007  | Logging             | ⭐⭐⭐⭐     | ✅ Must Have   |
| FR-010  | Notifications       | ⭐⭐⭐⭐     | ⚠️ Should Have |
| UX-001  | Main Dashboard      | ⭐⭐⭐⭐⭐    | ✅ Must Have   |
| UX-002  | System Tray         | ⭐⭐⭐⭐⭐    | ✅ Must Have   |
| UX-003  | Settings Window     | ⭐⭐⭐⭐     | ⚠️ Should Have |
| UX-004  | Log Viewer          | ⭐⭐⭐      | ⚠️ Should Have |
| NFR-001 | Performance         | ⭐⭐⭐⭐⭐    | ✅ Must Have   |
| NFR-002 | Reliability         | ⭐⭐⭐⭐⭐    | ✅ Must Have   |
| NFR-004 | Compatibility       | ⭐⭐⭐⭐     | ✅ Must Have   |
| TR-001  | Architecture        | ⭐⭐⭐⭐⭐    | ✅ Must Have   |
| TR-002  | PS Integration      | ⭐⭐⭐⭐⭐    | ✅ Must Have   |

### Phase 2 (Features) - Weeks 5-9

| Req ID | Requirement            | Priority | Status        |
| ------ | ---------------------- | -------- | ------------- |
| FR-004 | QoS Management         | ⭐⭐⭐      | ⚠️ Should Have |
| FR-006 | Hotspot Management     | ⭐⭐       | 🔵 Could Have  |
| FR-008 | Configuration Profiles | ⭐⭐⭐      | ⚠️ Should Have |
| FR-009 | Reporting & Analytics  | ⭐⭐⭐      | ⚠️ Should Have |
| UX-005 | First-Run Experience   | ⭐⭐⭐      | ⚠️ Should Have |
| UX-006 | Visual Design          | ⭐⭐⭐⭐     | ⚠️ Should Have |
| TR-003 | Data Persistence       | ⭐⭐⭐⭐     | ⚠️ Should Have |

### Phase 3 (Distribution) - Weeks 10-12

| Req ID | Requirement  | Priority | Status        |
| ------ | ------------ | -------- | ------------- |
| DR-001 | Installation | ⭐⭐⭐⭐     | ⚠️ Should Have |
| DR-002 | Distribution | ⭐⭐⭐⭐     | ⚠️ Should Have |
| DR-003 | Auto-Update  | ⭐⭐⭐      | ⚠️ Should Have |

### Out of Scope (Future)

| Req ID   | Requirement          | Priority | Status       |
| -------- | -------------------- | -------- | ------------ |
| NFR-007  | Internationalization | ⭐        | ❌ Won't Have |
| FR-006.5 | Auto-start Hotspot   | ⭐        | ❌ Won't Have |
| FR-009.7 | Scheduled Reports    | ⭐        | ❌ Won't Have |
| UX-004.6 | Log Search           | ⭐⭐       | 🔵 Could Have |

---

## ✅ ACCEPTANCE CRITERIA

### Phase 1 MVP Acceptance

**Definition of Done for Phase 1:**

Application is considered MVP-complete when:

1. ✅ **Core Functionality**
   - [ ] Monitors connection every 3 seconds
   - [ ] Displays real-time latency, jitter, packet loss
   - [ ] Automatically restarts adapter on connection loss
   - [ ] Switches DNS servers on failure
   - [ ] Logs all activities

2. ✅ **User Interface**
   - [ ] Main dashboard window displays metrics
   - [ ] System tray icon shows connection status
   - [ ] Start/Stop buttons work reliably
   - [ ] Settings window allows basic configuration
   - [ ] Minimize to tray works

3. ✅ **Technical Quality**
   - [ ] No critical bugs
   - [ ] CPU usage < 5%
   - [ ] Memory usage < 100MB
   - [ ] Runs for 24 hours without crashing
   - [ ] Works on Windows 10 21H2 and Windows 11

4. ✅ **Documentation**
   - [ ] README with installation instructions
   - [ ] Basic usage guide
   - [ ] Known issues documented

5. ✅ **Packaging**
   - [ ] MSI installer created
   - [ ] Installs successfully on clean system
   - [ ] Uninstaller removes all components

---

## 📊 PRIORITIZATION SUMMARY

### MoSCoW Analysis

**MUST HAVE (Critical for MVP):**
- Network monitoring with real-time metrics
- Automatic connection recovery
- DNS optimization
- System tray integration
- Basic UI (dashboard, settings)
- Logging
- Performance (low CPU/RAM)
- Windows 10/11 compatibility

**SHOULD HAVE (Important but not critical):**
- QoS management
- Configuration profiles
- Reporting/analytics
- Notifications
- TCP/IP optimizations
- Modern visual design
- MSI installer

**COULD HAVE (Nice to have):**
- Hotspot management
- Advanced log search
- PDF export
- Custom DNS servers
- First-run wizard

**WON'T HAVE (Explicitly out of scope):**
- Localization/i18n
- macOS/Linux support
- Microsoft Store
- Enterprise features
- Mobile app
- Cloud sync

---

## 🤝 STAKEHOLDER SIGN-OFF

### Requirements Review

**Date:** 2 de Octubre, 2025

**Reviewed By:**
- [x] Carlos Eduardo Zamora (Project Owner)
- [x] Mary (Business Analyst)

**Status:** ✅ **APPROVED**

### Change Request Process

For requirements changes post-approval:

1. **Document Change**: Describe proposed modification
2. **Impact Assessment**: Analyze effect on timeline/scope
3. **Stakeholder Review**: Get approval from project owner
4. **Update Document**: Revise this requirements document
5. **Communicate**: Notify all stakeholders of change

### Version History

| Version | Date       | Author | Changes                                   |
| ------- | ---------- | ------ | ----------------------------------------- |
| 1.0     | 2025-10-02 | Mary   | Initial requirements elicitation document |

---

## 📎 APPENDICES

### Appendix A: Glossary

| Term                  | Definition                                                   |
| --------------------- | ------------------------------------------------------------ |
| **Adaptive Recovery** | Escalating recovery strategies based on failure patterns     |
| **DNS Failover**      | Automatic switching to backup DNS server when primary fails  |
| **Jitter**            | Variation in network latency over time (standard deviation)  |
| **MoSCoW**            | Prioritization method: Must/Should/Could/Won't have          |
| **Packet Loss**       | Percentage of network packets that fail to reach destination |
| **QoS**               | Quality of Service - network traffic prioritization          |
| **Runspace**          | PowerShell execution environment                             |
| **System Tray**       | Windows taskbar notification area                            |
| **WPF**               | Windows Presentation Foundation - Microsoft GUI framework    |

---

### Appendix B: User Story Map

**Epic 1: Monitor Connection**
- As a user, I want to see current connection status
- As a user, I want to view latency trends over time
- As a power user, I want detailed metrics

**Epic 2: Recover Automatically**
- As a remote worker, I want automatic recovery so work isn't interrupted
- As a gamer, I want fast recovery to reconnect quickly
- As a user, I want to be notified when recovery occurs

**Epic 3: Optimize Network**
- As a user, I want the fastest DNS configured
- As a gamer, I want my game traffic prioritized
- As a user, I want optimized TCP/IP settings

**Epic 4: Configure & Control**
- As a user, I want to start/stop monitoring easily
- As a power user, I want to customize all settings
- As a user, I want different profiles for different scenarios

**Epic 5: Background Operation**
- As a user, I want the app to run in the system tray
- As a user, I want minimal CPU/RAM usage
- As a user, I want the app to start with Windows

---

### Appendix C: Risk Register (Requirements-Related)

| Risk                                       | Probability | Impact | Mitigation                                                          |
| ------------------------------------------ | ----------- | ------ | ------------------------------------------------------------------- |
| PowerShell integration too slow            | Medium      | High   | Profile early, optimize, convert critical functions to C# if needed |
| UI framework learning curve delays Phase 1 | Medium      | Medium | Use AI assistance, leverage WPF tutorials, start simple             |
| Scope creep extends timeline               | High        | Medium | Strict MoSCoW adherence, defer non-MUST features                    |
| Admin requirement alienates users          | Low         | Medium | Clear documentation, explain necessity                              |
| Users expect features out of MVP scope     | Medium      | Low    | Set expectations via README, roadmap visibility                     |

---

## 🎯 NEXT ACTIONS

### Immediate (This Week)
1. ✅ Complete requirements elicitation (this document)
2. [ ] Review requirements with project owner
3. [ ] Begin Phase 1 MVP development
4. [ ] Create WPF project structure
5. [ ] Implement PowerShell bridge proof-of-concept

### Short-Term (Weeks 2-3)
1. [ ] Implement FR-001 (Network Monitoring)
2. [ ] Implement FR-002 (Auto Recovery)
3. [ ] Implement UX-001 (Main Dashboard)
4. [ ] Implement UX-002 (System Tray)
5. [ ] Create basic settings window

### Medium-Term (Week 4)
1. [ ] MVP feature freeze
2. [ ] Bug fixing and polish
3. [ ] User testing with 5-10 users
4. [ ] Documentation (README, basic wiki)
5. [ ] Create MSI installer

---

**Document Status:** ✅ Complete and Approved  
**Last Updated:** 2 de Octubre, 2025  
**Next Review:** End of Phase 1 (Week 4) to assess requirements validity