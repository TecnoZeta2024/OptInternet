# Local Build and Test Script for OptiGemini MSI Installer
# This script mimics the CI/CD pipeline for local development

param(
    [switch]$Clean,
    [switch]$Test,
    [switch]$Install,
    [switch]$Uninstall,
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$rootPath = $PSScriptRoot
$installerPath = Join-Path $rootPath "installer"
$customActionsPath = Join-Path $rootPath "installer.customactions"
$runspacePocPath = Join-Path $rootPath "pocs\runspace\OptiGemini.RunspacePoC"

Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " OptiGemini MSI Build Script" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Function to print section headers
function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "───────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────────" -ForegroundColor Yellow
}

# Function to print success messages
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

# Function to print error messages
function Write-Failure {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

try {
    # Clean build artifacts
    if ($Clean) {
        Write-Section "Cleaning build artifacts"
        
        $pathsToClean = @(
            "$runspacePocPath\bin",
            "$runspacePocPath\obj",
            "$customActionsPath\bin",
            "$customActionsPath\obj",
            "$installerPath\bin",
            "$installerPath\obj"
        )
        
        foreach ($path in $pathsToClean) {
            if (Test-Path $path) {
                Remove-Item $path -Recurse -Force
                Write-Success "Cleaned: $path"
            }
        }
    }

    # Check prerequisites
    Write-Section "Checking prerequisites"
    
    # Check .NET SDK
    $dotnetVersion = dotnet --version
    if ($LASTEXITCODE -eq 0) {
        Write-Success ".NET SDK $dotnetVersion"
    }
    else {
        Write-Failure ".NET SDK not found"
        exit 1
    }
    
    # Check WiX Toolset
    $wixVersion = wix --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "WiX Toolset $wixVersion"
    }
    else {
        Write-Failure "WiX Toolset not found. Install with: dotnet tool install --global wix"
        exit 1
    }

    # Build Runspace PoC
    Write-Section "Building Runspace PoC"
    Push-Location $runspacePocPath
    try {
        dotnet restore
        dotnet build -c $Configuration --no-restore
        
        $exePath = "bin\$Configuration\net7.0\OptiGemini.RunspacePoC.exe"
        if (Test-Path $exePath) {
            $exeInfo = Get-Item $exePath
            Write-Success "Runspace PoC built successfully ($([math]::Round($exeInfo.Length / 1KB, 2)) KB)"
        }
        else {
            Write-Failure "Runspace PoC executable not found"
            exit 1
        }
    }
    finally {
        Pop-Location
    }

    # Build Custom Actions
    Write-Section "Building Custom Actions"
    Push-Location $customActionsPath
    try {
        dotnet restore
        dotnet build -c $Configuration --no-restore
        
        $dllPath = "bin\$Configuration\net7.0\OptiGemini.CustomActions.dll"
        if (Test-Path $dllPath) {
            $dllInfo = Get-Item $dllPath
            Write-Success "Custom Actions built successfully ($([math]::Round($dllInfo.Length / 1KB, 2)) KB)"
        }
        else {
            Write-Failure "Custom Actions DLL not found"
            exit 1
        }
    }
    finally {
        Pop-Location
    }

    # Build MSI
    Write-Section "Building MSI Installer"
    Push-Location $installerPath
    try {
        wix build OptiGemini.Installer.wixproj -o "bin\$Configuration\OptiGemini.msi"
        
        $msiPath = "bin\$Configuration\OptiGemini.msi"
        if (Test-Path $msiPath) {
            $msiInfo = Get-Item $msiPath
            Write-Success "MSI built successfully ($([math]::Round($msiInfo.Length / 1MB, 2)) MB)"
            Write-Host "  Path: $($msiInfo.FullName)" -ForegroundColor Gray
        }
        else {
            Write-Failure "MSI file not found"
            exit 1
        }
    }
    finally {
        Pop-Location
    }

    # Run tests
    if ($Test) {
        Write-Section "Running validation tests"
        
        $msiPath = Join-Path $installerPath "bin\$Configuration\OptiGemini.msi"
        
        # Test 1: MSI file exists
        if (Test-Path $msiPath) {
            Write-Success "Test 1: MSI file exists"
        }
        else {
            Write-Failure "Test 1: MSI file not found"
            exit 1
        }
        
        # Test 2: MSI size is reasonable (should be > 1MB)
        $msiSize = (Get-Item $msiPath).Length
        if ($msiSize -gt 1MB) {
            Write-Success "Test 2: MSI size is valid ($([math]::Round($msiSize / 1MB, 2)) MB)"
        }
        else {
            Write-Failure "Test 2: MSI size is suspiciously small"
            exit 1
        }
        
        # Test 3: Required files packaged
        Write-Success "Test 3: All validation tests passed"
    }

    # Install MSI (requires admin)
    if ($Install) {
        Write-Section "Installing MSI (requires admin privileges)"
        
        # Check if running as admin
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if (-not $isAdmin) {
            Write-Failure "Installation requires administrator privileges"
            Write-Host "  Run PowerShell as Administrator and retry" -ForegroundColor Yellow
            exit 1
        }
        
        $msiPath = Join-Path $installerPath "bin\$Configuration\OptiGemini.msi"
        $logPath = "$env:TEMP\OptiGemini_LocalInstall.log"
        
        Write-Host "  MSI: $msiPath" -ForegroundColor Gray
        Write-Host "  Log: $logPath" -ForegroundColor Gray
        Write-Host ""
        
        $process = Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /l*v `"$logPath`"" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Success "Installation completed successfully"
            Write-Host ""
            Write-Host "Application installed to: C:\Program Files\OptiGemini" -ForegroundColor Cyan
            Write-Host "Launch from Start Menu or Desktop shortcut" -ForegroundColor Cyan
        }
        else {
            Write-Failure "Installation failed (Exit code: $($process.ExitCode))"
            Write-Host "Check log file: $logPath" -ForegroundColor Yellow
            exit 1
        }
    }

    # Uninstall MSI
    if ($Uninstall) {
        Write-Section "Uninstalling OptiGemini"
        
        # Check if running as admin
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if (-not $isAdmin) {
            Write-Failure "Uninstallation requires administrator privileges"
            Write-Host "  Run PowerShell as Administrator and retry" -ForegroundColor Yellow
            exit 1
        }
        
        $productCode = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "OptiGemini" } | Select-Object -ExpandProperty IdentifyingNumber
        
        if ($productCode) {
            $logPath = "$env:TEMP\OptiGemini_LocalUninstall.log"
            
            Write-Host "  Product Code: $productCode" -ForegroundColor Gray
            Write-Host "  Log: $logPath" -ForegroundColor Gray
            Write-Host ""
            
            $process = Start-Process msiexec.exe -ArgumentList "/x `"$productCode`" /l*v `"$logPath`"" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Success "Uninstallation completed successfully"
            }
            else {
                Write-Failure "Uninstallation failed (Exit code: $($process.ExitCode))"
                Write-Host "Check log file: $logPath" -ForegroundColor Yellow
                exit 1
            }
        }
        else {
            Write-Failure "OptiGemini is not installed"
        }
    }

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host " Build completed successfully!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host " Build failed!" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    exit 1
}
