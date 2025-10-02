# OptiGemini MSI Installer

WiX Toolset 4.x installer project for OptiGemini Windows Desktop Application.

## Overview

This installer packages the OptiGemini runspace PoC binaries and provides:
- Prerequisite detection (.NET Desktop Runtime 7.x, PowerShell 7.4+)
- Clean installation to Program Files
- Start Menu and optional Desktop shortcuts
- Profile backup during uninstall
- Upgrade/downgrade handling

## Prerequisites for Building

- .NET 7 SDK
- WiX Toolset 4.0.5 or higher
- Visual Studio 2022 or VS Build Tools (optional, for IDE support)

### Installing WiX Toolset 4

```powershell
dotnet tool install --global wix --version 4.0.5
```

## Project Structure

```
installer/
├── OptiGemini.Installer.wixproj    # Main WiX project file
├── Product.wxs                      # Product definition and components
├── CustomActions.wxs                # Custom action declarations
├── Resources/                       # Installer assets
│   ├── default-config.json         # Default app configuration
│   ├── License.rtf                 # EULA
│   ├── Banner.bmp                  # Installer banner (493x58)
│   ├── Dialog.bmp                  # Installer dialog (493x312)
│   └── OptiGemini.ico              # Application icon (to be created)
└── README.md

installer.customactions/
├── OptiGemini.CustomActions.csproj  # Custom actions C# project
└── CustomActions.cs                 # Prerequisite checks & backup logic
```

## Building the Installer

### From Command Line

```powershell
# Navigate to project root
cd C:\Users\zamor\OptInternet

# Build the runspace PoC first (required for packaging)
cd pocs\runspace\OptiGemini.RunspacePoC
dotnet build -c Release
cd ..\..\..

# Build the custom actions DLL
cd installer.customactions
dotnet build -c Release
cd ..

# Build the MSI
cd installer
wix build -o bin\Release\OptiGemini.msi
```

### From Visual Studio

1. Open `OptiGemini.Installer.wixproj` in Visual Studio 2022
2. Set configuration to **Release**
3. Build Solution (Ctrl+Shift+B)
4. Output: `installer\bin\Release\OptiGemini.msi`

## Custom Actions

### CheckDotNetDesktopRuntime
- **When**: Before LaunchConditions (both UI and silent)
- **Purpose**: Validates .NET Desktop Runtime 7.x is installed
- **Behavior**: Prompts user with download link if missing, aborts if declined

### CheckPowerShell7
- **When**: After CheckDotNetRuntime
- **Purpose**: Validates PowerShell 7.4+ is installed
- **Behavior**: Warns user but continues (PowerShell is optional for limited mode)

### BackupUserProfiles
- **When**: Before RemoveFiles during uninstall
- **Purpose**: Backs up user profiles to `%APPDATA%\OptiGemini\OptiGemini_Profiles_Backup_YYYYMMDD_HHMMSS.zip`
- **Behavior**: Non-fatal, continues uninstall even if backup fails

## Installation Paths

- **Application**: `C:\Program Files\OptiGemini\`
- **Binaries**: `C:\Program Files\OptiGemini\bin\`
- **Modules**: `C:\Program Files\OptiGemini\Modules\`
- **Logs**: `C:\Program Files\OptiGemini\logs\`
- **User Data**: `%APPDATA%\OptiGemini\`
- **Profiles**: `%APPDATA%\OptiGemini\profiles\`

## Registry Keys

```
HKLM\Software\TecnoZeta\OptiGemini
├── InstallPath (REG_SZ): Installation directory
└── Version (REG_SZ): Installed version

HKCU\Software\TecnoZeta\OptiGemini
├── installed (REG_DWORD): Installed flag for shortcuts
└── DesktopShortcut (REG_DWORD): Desktop shortcut created flag
```

## Testing

### Manual Installation Test

```powershell
# Install
msiexec /i installer\bin\Release\OptiGemini.msi /l*v install.log

# Install with verbose logging
msiexec /i installer\bin\Release\OptiGemini.msi /l*v "%TEMP%\OptiGemini_Install.log"

# Uninstall
msiexec /x {ProductCode} /l*v uninstall.log

# Or use Add/Remove Programs
```

### Validation Checklist

- [ ] MSI builds without errors
- [ ] Installs successfully on Windows 11 23H2
- [ ] Installs successfully on Windows 10 21H2
- [ ] Prerequisite checks display correctly
- [ ] Start Menu shortcut created
- [ ] Desktop shortcut created (if selected)
- [ ] Application launches after install
- [ ] Uninstall removes all files except profile backup
- [ ] Profile backup created in %APPDATA%\OptiGemini
- [ ] Registry keys cleaned up after uninstall

## Upgrade Scenarios

The installer uses **MajorUpgrade** element with:
- **UpgradeCode**: `12345678-1234-1234-1234-123456789012` (fixed across versions)
- **ProductCode**: Auto-generated per build (enables side-by-side prevention)
- **Schedule**: `afterInstallInitialize` (removes old version early)

### Behavior:
- Installing **newer version** → Removes old, installs new
- Installing **same version** → Allowed (reinstall/repair)
- Installing **older version** → Blocked with error message

## Logging

Install logs are written to `%TEMP%\OptiGemini_Install.log` by default.

View logs:
```powershell
notepad "$env:TEMP\OptiGemini_Install.log"
```

## Known Limitations

1. **Icon**: OptiGemini.ico placeholder needs to be created with proper branding
2. **Localization**: Currently English-only (1033)
3. **Digital Signature**: MSI not signed (requires code signing certificate)
4. **Dependencies**: Assumes .NET 7 Desktop Runtime available for download

## Future Enhancements

- [ ] Code signing certificate integration
- [ ] Multi-language support (Spanish, Portuguese)
- [ ] Custom UI dialogs for profile selection
- [ ] Auto-update mechanism integration
- [ ] Silent install parameters documentation
- [ ] Group Policy deployment support (MST files)

## Troubleshooting

### "The system cannot find the file specified"
- Ensure runspace PoC is built in Release configuration first
- Check paths in Product.wxs match actual output directories

### "The Windows Installer Service could not be accessed"
- Run as Administrator
- Restart Windows Installer service: `net start msiserver`

### Custom actions fail during install
- Check `%TEMP%\OptiGemini_Install.log` for detailed error messages
- Ensure .NET 7 SDK is installed for custom actions DLL

### Changes not reflected in rebuilt MSI
- Clean solution: `wix build -clean`
- Delete `bin` and `obj` folders
- Increment ProductVersion in Product.wxs

## References

- [WiX Toolset 4 Documentation](https://wixtoolset.org/docs/v4/)
- [Windows Installer Documentation](https://docs.microsoft.com/en-us/windows/win32/msi/windows-installer-portal)
- [Best Practices for Authoring a Bootstrapper](https://wixtoolset.org/docs/v4/guides/bootstrapper/)
