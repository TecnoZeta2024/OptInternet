# 📋 PROJECT BRIEF
## OptiGemini v3.0 - Desktop Application Transformation

**Document Version:** 1.0  
**Date:** 2 de Octubre, 2025  
**Project Owner:** Carlos Eduardo Zamora  
**Business Analyst:** Mary  
**Repository:** [TecnoZeta2024/OptInternet](https://github.com/TecnoZeta2024/OptInternet)

---

## 📊 EXECUTIVE SUMMARY

### Vision Statement
Transform OptiGemini from a PowerShell console script into a professional-grade Windows 11 desktop application that provides aggressive network connection stabilization for users in areas with unstable internet connectivity.

### Project Purpose
OptiGemini was born from a critical real-world need: maintaining stable internet connectivity for real-time programming work in geographic areas with unreliable network infrastructure. This transformation aims to make this powerful tool accessible to non-technical users while preserving its aggressive monitoring and auto-recovery capabilities.

### Key Objectives
1. **Modernize User Experience**: Replace console dashboard with intuitive Windows 11 GUI
2. **Maintain Core Functionality**: Preserve all 1736 lines of proven network optimization logic
3. **Expand Accessibility**: Enable non-technical users to benefit from advanced network recovery
4. **Professional Distribution**: Create installer-ready application for public GitHub release
5. **Zero-Cost Implementation**: Utilize only free, open-source technologies

---

## 🎯 PROJECT GOALS & SUCCESS CRITERIA

### Primary Goals

| Goal             | Description                           | Success Metric               |
| ---------------- | ------------------------------------- | ---------------------------- |
| **Stability**    | Maintain connection ≥95% uptime       | Automated monitoring reports |
| **Performance**  | Recovery in <30 seconds               | Telemetry data               |
| **Usability**    | Non-technical users can install & use | User testing (n=10)          |
| **Distribution** | 500+ downloads in Q1 2026             | GitHub release analytics     |
| **Community**    | Active contributor base               | 5+ external contributors     |

### Key Performance Indicators (KPIs)

**Technical KPIs:**
- ✅ CPU Usage < 5% during monitoring
- ✅ Memory footprint < 100MB
- ✅ Application startup time < 3 seconds
- ✅ Network recovery success rate > 90%

**Adoption KPIs:**
- ⭐ 100+ GitHub stars (Month 1)
- 📥 500+ downloads (Quarter 1)
- 💬 20+ active discussions/issues
- 🐛 < 10 critical bugs reported

**Quality KPIs:**
- 📖 Complete documentation (README, Wiki, Video)
- 🎥 Tutorial video with 1000+ views
- ⚡ App launch success rate > 98%
- 🔄 Update adoption rate > 60%

---

## 👥 STAKEHOLDERS

### Primary Stakeholders

| Role                 | Name                  | Responsibility                        | Impact |
| -------------------- | --------------------- | ------------------------------------- | ------ |
| **Project Owner**    | Carlos Eduardo Zamora | Vision, development, final decisions  | High   |
| **Business Analyst** | Mary                  | Requirements, strategy, documentation | High   |
| **End Users**        | GitHub Community      | Testing, feedback, adoption           | High   |

### User Personas

#### Persona 1: "The Frustrated Remote Worker"
- **Demographics:** 25-45 years old, works from home
- **Location:** Rural/suburban areas with poor ISP infrastructure
- **Tech Skill:** Intermediate (can install software, basic troubleshooting)
- **Pain Points:** 
  - Frequent disconnections during video calls
  - Cannot work during peak hours (6-9 PM)
  - ISP support is unhelpful
- **Goals:** 
  - Maintain stable connection for work
  - Avoid manual network troubleshooting
  - Monitor network health in real-time

#### Persona 2: "The Competitive Gamer"
- **Demographics:** 18-30 years old, online gaming enthusiast
- **Location:** Areas with congested networks
- **Tech Skill:** Advanced (comfortable with settings, modifications)
- **Pain Points:**
  - High ping/latency ruins gameplay
  - Packet loss causes lag spikes
  - No QoS control from ISP
- **Goals:**
  - Minimize latency and jitter
  - Prioritize gaming traffic
  - Real-time network metrics

#### Persona 3: "The Tech-Savvy Tinkerer"
- **Demographics:** 20-50 years old, IT professional or enthusiast
- **Location:** Any
- **Tech Skill:** Expert (PowerShell, networking, system administration)
- **Pain Points:**
  - Wants automation for repetitive network tasks
  - Needs detailed logs and metrics
  - Open to contributing improvements
- **Goals:**
  - Understand and customize all optimizations
  - Extend functionality for specific use cases
  - Share knowledge with community

---

## 🔍 PROBLEM STATEMENT

### The Core Problem

**Users in areas with unstable internet connectivity experience:**
1. Frequent disconnections that disrupt real-time work
2. High latency and jitter during peak hours
3. Inability to maintain persistent connections
4. Limited technical knowledge to implement manual fixes
5. No affordable software solution for aggressive connection recovery

### Current State (OptiGemini v2.2 - PowerShell Script)

**Strengths:**
- ✅ Proven effectiveness (1736 lines of battle-tested code)
- ✅ Aggressive monitoring (3-second intervals)
- ✅ Multi-tier recovery strategy (DNS failover, adapter restart, QoS)
- ✅ Comprehensive logging
- ✅ Zero cost

**Limitations:**
- ❌ Requires PowerShell knowledge to configure
- ❌ Console-only interface intimidates non-technical users
- ❌ No visual feedback or real-time graphs
- ❌ Manual startup required (no system tray integration)
- ❌ Difficult to distribute (users must download PS1 file)
- ❌ No update mechanism

### Desired State (OptiGemini v3.0 - Desktop Application)

**Vision:**
A professional Windows 11 application with:
- ✅ Intuitive GUI with real-time dashboard
- ✅ One-click installation (MSI installer)
- ✅ System tray integration (runs in background)
- ✅ Visual network health indicators
- ✅ Configurable profiles (Home/Office/Gaming)
- ✅ Auto-update capability
- ✅ Comprehensive documentation and video tutorials
- ✅ Active community support

---

## 💡 PROPOSED SOLUTION

### Strategic Approach: **Incremental Modernization**

Rather than rewriting from scratch, we will **wrap the proven PowerShell core with a modern WPF GUI**, ensuring:
- Fast time-to-market (MVP in 2-4 weeks)
- Low risk (reusing 1736 lines of tested logic)
- Iterative improvement based on user feedback

### Architecture Overview

```
┌────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                      │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │         WPF Application (C# + XAML)                 │  │
│  │  - MainWindow (Dashboard)                           │  │
│  │  - SettingsWindow (Configuration)                   │  │
│  │  - LogViewer (Real-time logs)                       │  │
│  │  - System Tray Icon (Background operation)          │  │
│  └─────────────────────────────────────────────────────┘  │
│                         ↕                                  │
│              (PowerShell Remoting Bridge)                  │
│                         ↕                                  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │      BUSINESS LOGIC LAYER                           │  │
│  │                                                      │  │
│  │      OpTinternet.ps1 Core Engine                    │  │
│  │  - Network Monitoring                               │  │
│  │  - Adaptive Recovery                                │  │
│  │  - DNS Optimization                                 │  │
│  │  - QoS Management                                   │  │
│  │  - Performance Tracking                             │  │
│  └─────────────────────────────────────────────────────┘  │
│                         ↕                                  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │         DATA & CONFIGURATION LAYER                  │  │
│  │                                                      │  │
│  │  - config.json (Settings persistence)               │  │
│  │  - profiles.json (Connection profiles)              │  │
│  │  - OptiGemini_log_YYYY-MM-DD.txt (Logs)            │  │
│  │  - performance_history.db (SQLite - optional)       │  │
│  └─────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

### Technology Stack Decision

**Selected: WPF + PowerShell Core**

| Component         | Technology                      | Justification                                        |
| ----------------- | ------------------------------- | ---------------------------------------------------- |
| **GUI Framework** | WPF (.NET 6/7)                  | Mature, free, excellent tooling, native Windows feel |
| **UI Library**    | Material Design in XAML         | Modern, Windows 11 aesthetic, well-documented        |
| **Charts**        | LiveCharts2                     | Real-time capable, open-source, WPF-compatible       |
| **Backend**       | PowerShell 7.x                  | Reuse existing 1736 lines of proven code             |
| **Bridge**        | System.Management.Automation    | Official C#/PowerShell interop                       |
| **Configuration** | JSON (Newtonsoft.Json)          | Human-readable, easy to edit                         |
| **Logging**       | Text files + Serilog (optional) | Simple, no dependencies                              |
| **Installer**     | WiX Toolset 4.x                 | Industry standard, free, MSI output                  |
| **Updates**       | Squirrel.Windows                | Auto-update, GitHub integration                      |
| **CI/CD**         | GitHub Actions                  | Free for public repos, integrated                    |

**Alternatives Considered & Rejected:**

| Alternative       | Why Rejected                                     |
| ----------------- | ------------------------------------------------ |
| **WinUI 3**       | Too new, fewer resources, steeper learning curve |
| **Electron**      | Large bundle size (150MB+), slower performance   |
| **Avalonia**      | Cross-platform not needed, smaller community     |
| **.NET MAUI**     | Overkill for Windows-only app                    |
| **Rewrite to C#** | High risk, 4-6 weeks extra development time      |

---

## 📋 SCOPE DEFINITION

### In Scope ✅

**Phase 1: MVP (Weeks 1-4)**
- [ ] WPF project structure setup
- [ ] Main dashboard window with real-time metrics
- [ ] System tray icon with status indicator
- [ ] PowerShell integration layer
- [ ] Start/Stop/Pause monitoring controls
- [ ] Basic settings (SSID, password, aggressiveness)
- [ ] Log viewer window
- [ ] MSI installer (basic)

**Phase 2: Professional Features (Weeks 5-9)**
- [ ] Connection profiles (Home/Office/Gaming/Battery)
- [ ] Configuration persistence (%APPDATA%)
- [ ] Windows 11 toast notifications
- [ ] Real-time charts (latency, jitter, packet loss)
- [ ] Export reports (CSV/HTML)
- [ ] Light/Dark theme toggle
- [ ] Global hotkeys (Ctrl+Alt+O)
- [ ] Portable version (ZIP)

**Phase 3: Distribution (Weeks 10-12)**
- [ ] WinGet manifest
- [ ] GitHub Releases setup
- [ ] Auto-update implementation
- [ ] Video tutorial (5-10 min)
- [ ] Complete wiki documentation
- [ ] Issue/PR templates
- [ ] Community guidelines

### Out of Scope ❌

**Explicitly NOT included (deferred to future versions):**
- ❌ Machine learning / predictive analytics
- ❌ Mobile companion app
- ❌ Multi-device monitoring dashboard
- ❌ VPN integration
- ❌ macOS/Linux support
- ❌ Microsoft Store publication (costs $19/year)
- ❌ Localization (English only for v3.0)
- ❌ Cloud sync of settings
- ❌ Remote monitoring API

### Dependencies & Constraints

**Technical Dependencies:**
- .NET 6 SDK or later (free)
- PowerShell 7.x (free)
- Windows 10 21H2+ or Windows 11 (target platform)
- Administrator privileges (required for network modifications)
- Visual Studio 2022 Community Edition (free)

**Resource Constraints:**
- **Budget:** $0 (all free/open-source tools)
- **Team:** 1 developer (Carlos) + AI assistance
- **Time:** Part-time development (evenings/weekends)
- **Skills:** Intermediate C#/XAML, advanced PowerShell

**External Constraints:**
- Must work with consumer-grade network adapters
- Cannot require third-party licenses
- Must pass Windows SmartScreen (requires usage history)
- Subject to ISP limitations (cannot bypass hard throttling)

---

## 🗓️ PROJECT TIMELINE & MILESTONES

### Phase 1: MVP Development (2-4 weeks)

| Week       | Milestone         | Deliverables                              | Success Criteria                    |
| ---------- | ----------------- | ----------------------------------------- | ----------------------------------- |
| **Week 1** | Project Setup     | WPF solution, repo structure, CI pipeline | Successful build on GitHub Actions  |
| **Week 2** | Core Integration  | PowerShell bridge, basic monitoring       | Can call PS functions from C#       |
| **Week 3** | UI Implementation | Dashboard, system tray, controls          | Functional GUI showing live metrics |
| **Week 4** | MVP Polish        | Installer, basic docs, bug fixes          | Installable app, README complete    |

**Phase 1 Exit Criteria:**
- ✅ Application installs and runs on clean Windows 11
- ✅ Dashboard shows real-time latency/jitter/packet loss
- ✅ Monitoring can be started/stopped from GUI
- ✅ System tray icon reflects connection status
- ✅ Logs are viewable in UI
- ✅ No critical bugs

---

### Phase 2: Feature Enhancement (3-5 weeks)

| Week       | Milestone       | Deliverables                            | Success Criteria                  |
| ---------- | --------------- | --------------------------------------- | --------------------------------- |
| **Week 5** | Profiles System | Save/load connection profiles           | Users can switch between presets  |
| **Week 6** | Visualization   | LiveCharts integration, graphs          | Real-time charts update smoothly  |
| **Week 7** | Notifications   | Toast notifications, settings           | Users receive connection alerts   |
| **Week 8** | Advanced Config | All PS script params configurable       | Power users can tune all settings |
| **Week 9** | Polish & Export | Themes, report export, portable version | Professional look and feel        |

**Phase 2 Exit Criteria:**
- ✅ 3+ connection profiles working
- ✅ Charts render smoothly without lag
- ✅ Toast notifications trigger appropriately
- ✅ Config persists across restarts
- ✅ Exported reports are usable
- ✅ User testing validates UX improvements

---

### Phase 3: Distribution & Community (2-3 weeks)

| Week        | Milestone         | Deliverables                           | Success Criteria                            |
| ----------- | ----------------- | -------------------------------------- | ------------------------------------------- |
| **Week 10** | Package & Publish | WinGet manifest, GitHub Release v3.0.0 | Installable via `winget install OptiGemini` |
| **Week 11** | Documentation     | Wiki, video tutorial, troubleshooting  | <10 "how do I..." questions                 |
| **Week 12** | Community Launch  | Reddit/Forums post, issue templates    | 50+ downloads, 5+ GitHub stars              |

**Phase 3 Exit Criteria:**
- ✅ Published on GitHub Releases with changelog
- ✅ WinGet manifest merged (or pending)
- ✅ Video tutorial complete and posted
- ✅ Wiki has 10+ documentation pages
- ✅ 100+ downloads achieved
- ✅ Community feedback is positive

---

### Phase 4: Future Enhancements (Post v3.0)

**Planned for v3.1+:**
- Machine learning pattern detection
- Advanced scheduling (time-based profiles)
- Network topology visualization
- Integration with Discord/Telegram for alerts
- Remote monitoring capability
- Performance optimizations based on telemetry

---

## 💰 BUDGET & RESOURCES

### Budget Breakdown

| Category              | Item                         | Cost          | Notes                           |
| --------------------- | ---------------------------- | ------------- | ------------------------------- |
| **Development Tools** | Visual Studio 2022 Community | $0            | Free for open-source            |
|                       | .NET 6 SDK                   | $0            | Free                            |
|                       | WiX Toolset                  | $0            | Open-source                     |
| **Libraries**         | Material Design in XAML      | $0            | MIT License                     |
|                       | LiveCharts2                  | $0            | MIT License                     |
|                       | Newtonsoft.Json              | $0            | MIT License                     |
| **Infrastructure**    | GitHub repository            | $0            | Public repo                     |
|                       | GitHub Actions (CI/CD)       | $0            | 2000 min/month free             |
|                       | GitHub Releases (hosting)    | $0            | Unlimited for public repos      |
| **Distribution**      | WinGet manifest              | $0            | Free Microsoft catalog          |
| **Optional**          | Code signing certificate     | ~$100/year    | Improves trust (not required)   |
| **Total**             |                              | **$0 - $100** | Fully achievable with zero cost |

### Resource Allocation

**Developer Time Estimate:**

| Phase                  | Hours             | Weeks (Part-time) | Tasks                                   |
| ---------------------- | ----------------- | ----------------- | --------------------------------------- |
| Phase 1 (MVP)          | 60-80 hours       | 2-4 weeks         | Core development, integration, basic UI |
| Phase 2 (Features)     | 80-100 hours      | 3-5 weeks         | Advanced features, polish, testing      |
| Phase 3 (Distribution) | 40-60 hours       | 2-3 weeks         | Packaging, docs, community setup        |
| **Total**              | **180-240 hours** | **7-12 weeks**    | Complete v3.0 launch                    |

**Assumptions:**
- 15-20 hours per week available for development
- AI assistance (GitHub Copilot/Claude) reduces development time by ~30%
- Reusing existing PowerShell logic saves 60-80 hours

---

## 🚨 RISKS & MITIGATION STRATEGIES

### High-Priority Risks

| Risk                                     | Probability | Impact | Mitigation Strategy                                                               |
| ---------------------------------------- | ----------- | ------ | --------------------------------------------------------------------------------- |
| **C#/PowerShell integration complexity** | Medium      | High   | POC in Week 1; use System.Management.Automation with async patterns               |
| **Antivirus false positives**            | Medium      | High   | Document AV exclusions; consider code signing (~$100); build reputation over time |
| **Performance degradation with GUI**     | Low         | High   | Profile early; use background threads; optimize PowerShell calls                  |
| **Administrator privilege rejection**    | Low         | Medium | Clear documentation on why required; graceful degradation                         |

### Medium-Priority Risks

| Risk                               | Probability | Impact | Mitigation Strategy                                                |
| ---------------------------------- | ----------- | ------ | ------------------------------------------------------------------ |
| **WPF learning curve**             | Medium      | Medium | Start with simple UI; iterate; leverage AI assistance              |
| **ISP-specific incompatibilities** | Medium      | Medium | Configurable aggressiveness; "Safe Mode"; community testing        |
| **Windows SmartScreen warnings**   | High        | Medium | Document bypass procedure; build reputation; optional code signing |
| **Installer creation complexity**  | Low         | Medium | Use WiX Toolset tutorials; start simple; iterate                   |

### Low-Priority Risks

| Risk                                  | Probability | Impact | Mitigation Strategy                                                     |
| ------------------------------------- | ----------- | ------ | ----------------------------------------------------------------------- |
| **Low community adoption**            | Medium      | Low    | Focus on quality; promote in niche communities (Reddit r/homelab, etc.) |
| **Feature creep**                     | Medium      | Low    | Strict phase gates; defer non-MVP features                              |
| **Dependency updates breaking build** | Low         | Low    | Pin dependency versions; test before upgrading                          |

---

## 📊 SUCCESS METRICS & VALIDATION

### How We'll Measure Success

**Technical Validation:**
1. **Functional Testing:** All features work as documented
2. **Performance Testing:** Meets CPU/RAM/startup time KPIs
3. **Stability Testing:** 48-hour stress test without crashes
4. **Compatibility Testing:** Works on Win10 21H2, Win11 21H2, Win11 22H2

**User Validation:**
1. **Beta Testing:** 10 users test MVP for 1 week
2. **Usability Testing:** 5 non-technical users complete install & setup
3. **Survey:** 80%+ users rate experience 4/5 or higher
4. **Support Metrics:** <20% of users need help after reading docs

**Adoption Metrics:**
1. **Downloads:** 100+ in first month, 500+ in first quarter
2. **Engagement:** 20+ GitHub issues/discussions
3. **Retention:** 60%+ of installers check for updates
4. **Community:** 5+ external code contributions

### Definition of Done (DoD)

**For Each Phase:**
- [ ] All planned features implemented
- [ ] No critical bugs (P0)
- [ ] <5 high-priority bugs (P1)
- [ ] All code reviewed (self or AI-assisted)
- [ ] Unit tests passing (if applicable)
- [ ] Documentation updated
- [ ] Release notes written

**For Project Completion:**
- [ ] v3.0.0 published on GitHub Releases
- [ ] MSI installer tested on 3+ machines
- [ ] Video tutorial published and linked
- [ ] Wiki has comprehensive documentation
- [ ] 100+ downloads achieved
- [ ] Positive community feedback (80%+ satisfaction)

---

## 📝 ASSUMPTIONS

**Technical Assumptions:**
1. Users have Windows 10 21H2+ or Windows 11
2. Users have administrator access
3. .NET runtime can be bundled or is installed
4. Network adapters support standard Windows APIs
5. PowerShell 7 features are backward compatible

**Business Assumptions:**
1. Target users will find the app via GitHub/search
2. Open-source model will attract contributors
3. Free model is sustainable (no support costs)
4. Similar pain points exist in broader market
5. Video tutorial is sufficient for onboarding

**User Assumptions:**
1. Users can download and run an MSI installer
2. Users understand they need admin privileges
3. Users will read basic documentation
4. Users have basic understanding of network concepts
5. Users will report bugs via GitHub Issues

---

## 🤝 COMMUNICATION PLAN

### Stakeholder Updates

**Internal (Developer):**
- Daily: Personal progress tracking
- Weekly: GitHub commit log, milestone updates
- Phase completion: Self-review, retrospective

**External (Community):**
- Monthly: Blog post or Reddit update on progress
- Milestone: GitHub Release with detailed notes
- Major release: Video update, social media announcement

### Documentation Strategy

**For Users:**
- README.md: Quick start, feature overview
- Wiki: Detailed guides, troubleshooting, FAQ
- Video: Installation and basic usage (5-10 min)
- In-app: Tooltips, help links

**For Developers:**
- CONTRIBUTING.md: How to contribute
- CODE_OF_CONDUCT.md: Community guidelines
- Architecture docs: System design, code structure
- API docs: If exposing programmatic interface

---

## ✅ APPROVAL & SIGN-OFF

### Project Approval

**Approved by:**
- [x] Carlos Eduardo Zamora (Project Owner)
- [x] Mary (Business Analyst)

**Date:** 2 de Octubre, 2025

### Change Request Process

For significant scope changes:
1. Document proposed change and rationale
2. Assess impact on timeline/resources
3. Update this brief with change log
4. Proceed if benefits outweigh costs

---

## 📎 APPENDICES

### Appendix A: Related Documents
- [Brainstorming Session Output](./Brainstorming-Session-GUI-Transformation.md)
- [copilot-instructions.md](../.github/copilot-instructions.md)
- [OpTinternet.ps1](../OpTinternet.ps1) (current implementation)

### Appendix B: Key Terms Glossary

| Term                  | Definition                                             |
| --------------------- | ------------------------------------------------------ |
| **QoS**               | Quality of Service - Traffic prioritization            |
| **Jitter**            | Variation in latency over time                         |
| **DNS Failover**      | Automatic switching to backup DNS server               |
| **Adaptive Recovery** | Escalating repair strategies based on failure patterns |
| **System Tray**       | Windows taskbar notification area                      |
| **MSI**               | Microsoft Installer package format                     |
| **WPF**               | Windows Presentation Foundation (GUI framework)        |

### Appendix C: Reference Architecture Diagram

```
User Interaction Flow:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  User clicks "Start Monitoring"                             │
│         ↓                                                   │
│  MainWindow.xaml.cs → MonitoringService.StartAsync()       │
│         ↓                                                   │
│  PowerShellBridge.ExecuteScript("Start-Monitoring")        │
│         ↓                                                   │
│  OpTinternet.ps1 → Begin monitoring loop                   │
│         ↓                                                   │
│  Metrics collected (latency, jitter, packet loss)          │
│         ↓                                                   │
│  PowerShellBridge.OnMetricsUpdated event                   │
│         ↓                                                   │
│  MainWindow updates charts & indicators                    │
│         ↓                                                   │
│  User sees real-time dashboard                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 NEXT ACTIONS

### Immediate (This Week)
1. ✅ Finalize and approve this Project Brief
2. [ ] Set up WPF project structure in Visual Studio
3. [ ] Create basic MainWindow.xaml layout
4. [ ] Implement PowerShell bridge proof-of-concept
5. [ ] Test calling `Test-InternetConnection` from C#

### Short-Term (Next 2 Weeks)
1. [ ] Complete dashboard UI with placeholders
2. [ ] Integrate real monitoring data
3. [ ] Implement system tray icon
4. [ ] Create settings window
5. [ ] First alpha build

### Medium-Term (Weeks 3-4)
1. [ ] Beta testing with 5-10 users
2. [ ] Bug fixes and polish
3. [ ] Create MSI installer
4. [ ] Write comprehensive README
5. [ ] MVP release (v3.0.0-beta)

---

**Document Status:** ✅ Approved and Active  
**Last Updated:** 2 de Octubre, 2025  
**Next Review:** End of Phase 1 (Week 4)