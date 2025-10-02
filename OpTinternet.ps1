# >> FUNCION NUEVA: Verificar tamaño de consola
function Test-ConsoleSize {
    $minWidth = 80
    $minHeight = 30
    $currentWidth = $Host.UI.RawUI.WindowSize.Width
    $currentHeight = $Host.UI.RawUI.WindowSize.Height
    if ($currentWidth -lt $minWidth -or $currentHeight -lt $minHeight) {
        Clear-Host
        # Validar que minWidth sea al menos 1 antes de multiplicar
        $safeWidth = [Math]::Max(1, $minWidth - 1)
        Write-Host "=" -ForegroundColor Red -NoNewline
        Write-Host ("=" * $safeWidth) -ForegroundColor Red
        Write-Host "|" -NoNewline -ForegroundColor Red
        Write-Host "  [ERROR] El tamaño de la consola es demasiado pequeño para mostrar el dashboard correctamente." -ForegroundColor White
        Write-Host "|" -NoNewline -ForegroundColor Red
        Write-Host "  Por favor, ajusta la ventana a al menos $minWidth columnas x $minHeight filas." -ForegroundColor Yellow
        Write-Host "|" -NoNewline -ForegroundColor Red
        Write-Host "  Recomendado: Haz clic en la esquina y arrastra para ampliar la ventana." -ForegroundColor Gray
        Write-Host "=" -ForegroundColor Red -NoNewline
        Write-Host ("=" * $safeWidth) -ForegroundColor Red
        Start-Sleep -Seconds 5
        exit 1
    }
}
# >> FUNCION NUEVA: Spinner visual para operaciones largas
function Show-Spinner {
    param(
        [string]$Message = "Procesando...",
        [int]$DurationSeconds = 5
    )
    $spinnerChars = @("|", "/", "-", "\\")
    $startTime = Get-Date
    $i = 0
    while ($true) {
        if (((Get-Date) - $startTime).TotalSeconds -ge $DurationSeconds) { break }
        Set-CursorPosition -X 40 -Y 44
        Write-Host -ForegroundColor Cyan -NoNewline (" " + $spinnerChars[$i % $spinnerChars.Count] + " $Message ")
        Start-Sleep -Milliseconds 200
        $i++
    }
    # Limpiar spinner con validacion segura
    Set-CursorPosition -X 40 -Y 44
    $clearLength = [Math]::Max(0, $Message.Length + 4)
    Write-Host -NoNewline (" " * $clearLength)
}

#=======================================================================================
#                           SCRIPT OPTIGEMINI v2.2 - FINAL BUILD
# Creado por: Carlos Eduardo Zamora & Gemini AI
# Fecha: 2025-07-31
# Descripcion: Sistema avanzado de optimizacion y estabilizacion de conexiones de red
#              con monitoreo en tiempo real, diagnosticos automaticos, QoS inteligente
#              y registro de eventos para maxima estabilidad.
#=======================================================================================

#region GLOBAL SCRIPT CONFIG
# --- Log File Configuration ---
$script:LogFile = Join-Path $PSScriptRoot "OptiGemini_log.txt"

# --- Function to Write to Log ---
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] - $Message"
    try {
        Add-Content -Path $script:LogFile -Value $logEntry -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        Write-Host "[FATAL] No se puede escribir en el archivo de log: $($script:LogFile)" -ForegroundColor Red
    }
}

# --- Function to Setup Console Encoding ---
function Set-ConsoleEncoding {
    try {
        # Configurar codificacion de consola para caracteres especiales
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::InputEncoding = [System.Text.Encoding]::UTF8
        
        # Para Windows PowerShell 5.1, tambien configurar el host
        if ($PSVersionTable.PSVersion.Major -eq 5) {
            $OutputEncoding = [System.Text.Encoding]::UTF8
        }
    }
    catch {
        Write-Log -Message "Advertencia: No se pudo configurar la codificacion UTF-8 en la consola." -Level "WARN"
    }
}
#endregion

#=======================================================================================
#                           INICIO DEL SCRIPT
#=======================================================================================


# Verificar tamaño de consola antes de continuar
Test-ConsoleSize

# Verificar permisos de administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[WARNING] ERROR CRITICO: Este script requiere permisos de administrador" -ForegroundColor Red
    Write-Host "Por favor, ejecuta PowerShell como administrador y vuelve a intentar." -ForegroundColor Yellow
    pause
    exit 1
}

# Configurar codificacion de consola para caracteres especiales
Set-ConsoleEncoding

# Clean previous log file and log the script start
Remove-Item -Path $script:LogFile -ErrorAction SilentlyContinue
Write-Log -Message "================ Script Initialized ================" -Level "SYSTEM"

#region VARIABLES Y CONFIGURACION INICIAL
# --------------------------------------------------------------------------------------
# Configuracion del Hotspot (MODIFICAR SI ES NECESARIO)
# --------------------------------------------------------------------------------------
$SSID = "OptiGemini_5G"
$Password = "gemini1234"

# --------------------------------------------------------------------------------------
# Configuracion de Monitoreo Avanzado
# --------------------------------------------------------------------------------------
$PrimaryCheckAddress = "8.8.8.8"        # DNS de Google
$SecondaryCheckAddress = "1.1.1.1"       # DNS de Cloudflare
$TertiaryCheckAddress = "208.67.222.222" # OpenDNS
$CheckIntervalSeconds = 3                 # Intervalo optimizado para deteccion rapida
$MaxRetries = 5                          # Aumentado para mayor tolerancia
$RetryDelaySeconds = 1                   # Reducido para respuesta mas rapida
$LatencyThreshold = 150                  # Umbral de latencia en ms
$PacketLossThreshold = 5                 # Umbral de perdida de paquetes en %
$JitterThreshold = 30                    # Umbral de jitter en ms (variacion de latencia)

# --------------------------------------------------------------------------------------
# Variables de Estado y Monitoreo Premium
# --------------------------------------------------------------------------------------
$script:startTime = [datetime]::Now
$script:reconnectionCount = 0
$script:totalDowntimeStopwatch = [System.Diagnostics.Stopwatch]::new()
$script:isDown = $false
$script:currentAction = "[INIT] Iniciando OptiGemini Premium..."
$script:lastIpAddress = "Detectando..."
$script:hotspotActive = $false
$script:currentLatency = 0
$script:averageLatency = 0
$script:packetLoss = 0
$script:currentJitter = 0
$script:connectionType = "Detectando..."
$script:networkSpeed = "Midiendo..."
$script:optimalDNS = $PrimaryCheckAddress
$script:performanceHistory = @()
$script:lastSpeedTest = [datetime]::MinValue
$script:systemOptimized = $false
$script:adapterId = ""
$script:adapterDescription = ""
$script:osVersionString = "Detectando..."
$script:degradedConnectionCycles = 0
$script:dashboardInitialized = $false
$script:logMessages = @()

# Variables adicionales de monitoreo avanzado
$script:memoryUsage = 0
$script:cpuUsage = 0
$script:diskUsage = 0
$script:networkErrors = 0
$script:lastErrorTime = [datetime]::MinValue
$script:totalBytesReceived = 0
$script:totalBytesSent = 0
$script:peakLatency = 0
$script:minLatency = 999999
$script:connectionStability = "Estable"
$script:dnsResponseTime = 0
$script:lastOptimizationTime = [datetime]::MinValue
$script:optimizationCount = 0
$script:criticalErrors = @()
$script:performanceScore = 100
$script:currentUploadSpeed = 0
$script:currentDownloadSpeed = 0
$script:lastNetworkStats = $null
$script:lastStatsTime = $null
$script:lastNetworkStats = $null
$script:lastStatsTime = [datetime]::MinValue
#endregion

#region FUNCIONES PRINCIPALES

# >> FUNCION AUXILIAR: Validacion segura de numeros para multiplicaciones
function Get-SafeMultiplier {
    param(
        [Parameter(Mandatory)]
        $Value,
        [int]$MinValue = 0,
        [int]$MaxValue = 1000
    )
    
    try {
        $numValue = [int]$Value
        return [Math]::Max($MinValue, [Math]::Min($MaxValue, $numValue))
    }
    catch {
        return $MinValue
    }
}

# >> FUNCIONES AUXILIARES: Manejo de cursor para dashboard estatico
function Set-CursorPosition {
    param(
        [int]$X, 
        [int]$Y
    )
    try {
        # Validar que las coordenadas esten dentro de limites razonables
        $safeX = [Math]::Max(0, [Math]::Min(200, $X))
        $safeY = [Math]::Max(0, [Math]::Min(100, $Y))
        
        $Host.UI.RawUI.CursorPosition = @{ X = $safeX; Y = $safeY }
    }
    catch {
        # Fallback silencioso si no se puede posicionar cursor
        # Esto evita errores en entornos donde el cursor no se puede mover
    }
}

function Add-LogMessage {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $script:logMessages += "[$timestamp] $Message"
    
    # Mantener solo los ultimos 8 mensajes para la zona de log
    if ($script:logMessages.Count -gt 8) {
        $script:logMessages = $script:logMessages[-8..-1]
    }
}

# >> FUNCION NUEVA: Actualizar metricas adicionales del sistema
function Update-SystemMetrics {
    try {
        # Memoria
        $memInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($memInfo) {
            $script:memoryUsage = [math]::Round((($memInfo.TotalVisibleMemorySize - $memInfo.FreePhysicalMemory) / $memInfo.TotalVisibleMemorySize) * 100, 1)
        }
        
        # CPU (promedio rapido)
        $cpuSample = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Measure-Object -Property LoadPercentage -Average
        if ($cpuSample) {
            $script:cpuUsage = [math]::Round($cpuSample.Average, 1)
        }
        
        # Disco principal
        $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($diskInfo) {
            $script:diskUsage = [math]::Round((($diskInfo.Size - $diskInfo.FreeSpace) / $diskInfo.Size) * 100, 1)
        }
        
        # Actualizaciones de latencia
        if ($script:currentLatency -gt 0) {
            if ($script:currentLatency -gt $script:peakLatency) {
                $script:peakLatency = $script:currentLatency
            }
            if ($script:currentLatency -lt $script:minLatency -and $script:currentLatency -gt 0) {
                $script:minLatency = $script:currentLatency
            }
        }
        
        # Score de rendimiento basico
        $latencyScore = if ($script:currentLatency -le 50) { 100 } elseif ($script:currentLatency -le 100) { 80 } elseif ($script:currentLatency -le 200) { 60 } else { 30 }
        $lossScore = if ($script:packetLoss -eq 0) { 100 } elseif ($script:packetLoss -le 1) { 90 } elseif ($script:packetLoss -le 5) { 70 } else { 40 }
        $script:performanceScore = [math]::Round(($latencyScore + $lossScore) / 2, 0)
        
    }
    catch {
        Add-LogMessage -Message "[WARN] Error actualizando métricas del sistema: $($_.Exception.Message)"
    }
}

function Set-CurrentAction {
    param([string]$Action)
    $script:currentAction = $Action
    Add-LogMessage -Message $Action
}

function Write-PaddedField {
    param(
        [int]$Line,
        [int]$Column,
        [string]$Value,
        [int]$Width,
        [string]$Color = "White",
        [string]$Align = "Left"
    )
    
    # Validaciones de seguridad
    if ([string]::IsNullOrEmpty($Value)) { $Value = "" }
    $safeWidth = Get-SafeMultiplier -Value $Width -MinValue 1 -MaxValue 100
    
    # Truncar y ajustar padding
    if ($Value.Length -gt $safeWidth) {
        $Value = $Value.Substring(0, $safeWidth)
    }
    
    # Mejorar padding para campos cortos
    if ($Align -eq "Right") {
        $PaddedValue = $Value.PadLeft($safeWidth)
    }
    else {
        $PaddedValue = $Value.PadRight($safeWidth)
    }
    
    try {
        Set-CursorPosition -X $Column -Y $Line
        Write-Host $PaddedValue -ForegroundColor $Color -NoNewline
    }
    catch {
        # Fallback silencioso
    }
}

function Get-Bar {
    param(
        [double]$Value,
        [double]$MaxValue,
        [int]$Width,
        [string]$Color
    )
    
    # Validaciones de seguridad
    $safeValue = [Math]::Max(0, $Value)
    $safeMaxValue = [Math]::Max(1, $MaxValue)
    $safeWidth = [Math]::Max(1, [Math]::Min(50, $Width)) # Limitar a máximo 50 chars
    
    $percentage = $safeValue / $safeMaxValue
    $filledWidth = [Math]::Max(0, [int]($percentage * $safeWidth))
    $emptyWidth = [Math]::Max(0, $safeWidth - $filledWidth)
    
    # Usar bloques Unicode para barra visual
    $filledChar = "█"
    $emptyChar = "░"
    $bar = "[" + ($filledChar * $filledWidth) + ($emptyChar * $emptyWidth) + "]"
    return $bar
}

# >> FUNCION PREMIUM: Obtener metricas avanzadas de red
function Get-NetworkMetrics {
    try {
        # Medir latencia con ping detallado y calcular jitter
        $pingResult = Test-Connection -ComputerName $script:optimalDNS -Count 4 -ErrorAction SilentlyContinue
        if ($pingResult -and ($pingResult | Where-Object { $_.StatusCode -eq 0 }).Count -gt 0) {
            $responseTimes = ($pingResult | Where-Object { $_.StatusCode -eq 0 }).ResponseTime
            $script:currentLatency = ($responseTimes | Measure-Object -Average).Average
            
            # Calcular Jitter (desviacion estandar de la latencia)
            if ($responseTimes.Count -gt 1) {
                $mean = $script:currentLatency
                $sumOfSquares = ($responseTimes | ForEach-Object { [Math]::Pow(($_ - $mean), 2) } | Measure-Object -Sum).Sum
                $script:currentJitter = [Math]::Sqrt($sumOfSquares / $responseTimes.Count)
            }
            else {
                $script:currentJitter = 0 # No se puede calcular jitter con un solo ping
            }

            $script:averageLatency = if ($script:performanceHistory.Latency) {
                ($script:performanceHistory.Latency | Measure-Object -Average).Average
            }
            else { $script:currentLatency }
            
            $packetsSent = $pingResult.Count
            $packetsReceived = $responseTimes.Count
            $script:packetLoss = if ($packetsSent -gt 0) { ((($packetsSent - $packetsReceived) / $packetsSent) * 100) } else { 100 }
        }
        else {
            # Si el ping falla, establecer metricas a valores de error
            $script:currentLatency = 0
            $script:currentJitter = 0
            $script:packetLoss = 100
        }
        
        # Detectar tipo de conexion
        $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike "*Hosted Network*" } | Select-Object -First 1
        if ($activeAdapter) {
            $script:adapterId = $activeAdapter.Name
            $script:adapterDescription = $activeAdapter.InterfaceDescription
            
            switch -Regex ($activeAdapter.InterfaceDescription) {
                "Ethernet|LAN" { $script:connectionType = "[ETH] Ethernet" }
                "Wi-Fi|Wireless|802.11" { $script:connectionType = "[WIFI] Wi-Fi" }
                "USB|Mobile|Phone" { $script:connectionType = "[USB] USB Tethering" }
                "Bluetooth" { $script:connectionType = "[BT] Bluetooth" }
                default { $script:connectionType = "[NET] Otro" }
            }
            
            # Velocidad del enlace
            $linkSpeed = $activeAdapter.LinkSpeed
            if ($linkSpeed -match "(\d+)\s*(\w+)") {
                $script:networkSpeed = "$($matches[1]) $($matches[2])"
            }
        }
        
        # Agregar metricas al historial
        $script:performanceHistory += @{
            Timestamp   = [datetime]::Now
            Latency     = $script:currentLatency
            PacketLoss  = $script:packetLoss
            Jitter      = $script:currentJitter
            IsConnected = $script:currentLatency -gt 0
        }
        
        # Mantener solo las ultimas 20 mediciones
        if ($script:performanceHistory.Count -gt 20) {
            $script:performanceHistory = $script:performanceHistory[-20..-1]
        }
        
    }
    catch {
        Write-Log -Message "Error en Get-NetworkMetrics: $($_.Exception.Message)" -Level "ERROR"
        Write-Debug "Error obteniendo metricas: $($_.Exception.Message)"
    }
}

# >> FUNCION PREMIUM: Dashboard con visualizacion avanzada
function Show-PremiumDashboard {
    # SOLO limpiar en la primera ejecucion o si se fuerza
    if (-not $script:dashboardInitialized -or $args[0] -eq "ForceRefresh") {
        Clear-Host
        
        # Dibujar estructura estatica del dashboard UNA SOLA VEZ
        Show-StaticDashboard
        
        $script:dashboardInitialized = $true
        $script:logMessages = @()  # Inicializar array de mensajes de log
    }
    
    # Actualizar metricas en tiempo real
    Get-NetworkMetrics
    
    # Actualizar metricas adicionales del sistema
    Update-SystemMetrics
    
    # Actualizar solo los campos dinamicos
    Update-DynamicFields
    
    # Actualizar zona de log
    Update-LogArea
}

# >> FUNCION: Dibujar estructura estatica del dashboard
function Show-StaticDashboard {
    try {
        # Header principal - diseño monocromatico
        $headerWidth = Get-SafeMultiplier -Value 70 -MinValue 50 -MaxValue 100
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
        Write-Host -NoNewline -ForegroundColor Cyan "|"
        Write-Host -NoNewline -ForegroundColor White "         OPTIGEMINI v2.2 - DASHBOARD AVANZADO         "
        Write-Host -ForegroundColor Cyan "|"
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
    
    
        # Linea 4: Tiempo y Sistema - ESTRUCTURA FIJA
        Write-Host "| Hora: " -NoNewline -ForegroundColor Cyan
        Write-Host (" " * 18) -NoNewline  # Espacio para tiempo
        Write-Host "| Sistema: " -NoNewline -ForegroundColor Cyan  
        Write-Host (" " * 30) -NoNewline  # Espacio para OS info
        Write-Host "|" -ForegroundColor Cyan
    
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
    
        # SECCION HOTSPOT
        Write-Host -NoNewline -ForegroundColor Cyan "|"
        Write-Host -NoNewline -ForegroundColor White "                  ESTADO DEL HOTSPOT                  "
        Write-Host -ForegroundColor Cyan "|"
        Write-Host "-" -ForegroundColor Gray -NoNewline
        Write-Host ("-" * $headerWidth) -ForegroundColor Gray
    
        # Linea 8: Hotspot info - ESTRUCTURA FIJA
        Write-Host "| Estado: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 12) -NoNewline  # Espacio para estado
        Write-Host "| SSID: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 15) -NoNewline  # Espacio para SSID
        Write-Host "| Clientes: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 3) -NoNewline   # Espacio para clientes
        Write-Host " |" -ForegroundColor Cyan
    
    
        # SECCION CONEXION
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
        Write-Host -NoNewline -ForegroundColor Cyan "|"
        Write-Host -NoNewline -ForegroundColor White "               INFORMACION DE CONEXION               "
        Write-Host -ForegroundColor Cyan "|"
        Write-Host "-" -ForegroundColor Gray -NoNewline
        Write-Host ("-" * $headerWidth) -ForegroundColor Gray
    
        # Linea 12: Tipo de conexion y velocidad
        Write-Host "| Tipo: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 15) -NoNewline  # Espacio para tipo
        Write-Host "| Velocidad: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 15) -NoNewline  # Espacio para velocidad
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 13: IP externa y DNS
        Write-Host "| IP Externa: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 13) -NoNewline  # Espacio para IP
        Write-Host "| DNS: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 20) -NoNewline  # Espacio para DNS
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 14: Adaptador
        Write-Host "| Adaptador: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 58) -NoNewline  # Espacio para adaptador
        Write-Host "|" -ForegroundColor Cyan
    
        # SECCION RENDIMIENTO
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
        Write-Host -NoNewline -ForegroundColor Cyan "|"
        Write-Host -NoNewline -ForegroundColor White "               METRICAS DE RENDIMIENTO               "
        Write-Host -ForegroundColor Cyan "|"
        Write-Host "-" -ForegroundColor Gray -NoNewline
        Write-Host ("-" * $headerWidth) -ForegroundColor Gray
    
        # Linea 18: Latencia
        Write-Host "| Latencia: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 58) -NoNewline  # Espacio para latencia
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 19: Jitter 
        Write-Host "| Jitter: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 60) -NoNewline  # Espacio para jitter
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 20: Perdida de paquetes
        Write-Host "| Paquetes: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 58) -NoNewline  # Espacio para paquetes
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 21: Trafico de datos
        Write-Host "| Trafico: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 59) -NoNewline  # Espacio para trafico
        Write-Host "|" -ForegroundColor Cyan
    
        # SECCION ESTABILIDAD
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
        Write-Host -NoNewline -ForegroundColor Cyan "|"
        Write-Host -NoNewline -ForegroundColor White "              ESTADISTICAS DE ESTABILIDAD              "
        Write-Host -ForegroundColor Cyan "|"
        Write-Host "-" -ForegroundColor Gray -NoNewline
        Write-Host ("-" * $headerWidth) -ForegroundColor Gray
    
        # Linea 25: Disponibilidad
        Write-Host "| Disponibilidad: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 53) -NoNewline   # Espacio para disponibilidad
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 26: Reconexiones
        Write-Host "| Reconexiones: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 55) -NoNewline   # Espacio para reconexiones
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 27: Tiempo activo
        Write-Host "| Tiempo Activo: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 54) -NoNewline  # Espacio para tiempo activo
        Write-Host "|" -ForegroundColor Cyan
    
        # SECCION ESTADO OPERATIVO
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
        Write-Host -NoNewline -ForegroundColor Cyan "|"
        Write-Host -NoNewline -ForegroundColor White "              ESTADO OPERATIVO EN VIVO              "
        Write-Host -ForegroundColor Cyan "|"
        Write-Host "-" -ForegroundColor Gray -NoNewline
        Write-Host ("-" * $headerWidth) -ForegroundColor Gray
    
        # Linea 31: Accion actual
        Write-Host "| Accion: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 61) -NoNewline  # Espacio para accion
        Write-Host "|" -ForegroundColor Cyan
    
        # Linea 32: Historial grafico
        Write-Host "| Historial: " -NoNewline -ForegroundColor Gray
        Write-Host (" " * 58) -NoNewline  # Espacio para historial
        Write-Host "|" -ForegroundColor Cyan
    
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
    
        # SECCION LOG EN VIVO
        Write-Host -NoNewline -ForegroundColor Cyan "|"
        Write-Host -NoNewline -ForegroundColor White "               ACTIVIDAD EN TIEMPO REAL               "
        Write-Host -ForegroundColor Cyan "|"
        Write-Host "-" -ForegroundColor Gray -NoNewline
        Write-Host ("-" * $headerWidth) -ForegroundColor Gray
    
        # 8 lineas para log (lineas 36-43)
        for ($i = 1; $i -le 8; $i++) {
            Write-Host "|" -NoNewline -ForegroundColor Cyan
            Write-Host (" " * $headerWidth) -NoNewline
            Write-Host "|" -ForegroundColor Cyan
        }
    
        Write-Host "=" -ForegroundColor Cyan -NoNewline
        Write-Host ("=" * $headerWidth) -ForegroundColor Cyan
        Write-Host "[INFO] Presiona CTRL+C para detener | " -NoNewline -ForegroundColor Gray
        Write-Host "Actualizando cada $CheckIntervalSeconds segundos" -ForegroundColor Yellow
    
    }
    catch {
        Write-Host "[ERROR] Error al dibujar dashboard estatico: $($_.Exception.Message)" -ForegroundColor Red
        # Fallback a dashboard simplificado
        Clear-Host
        Write-Host "==== OPTIGEMINI v2.2 - MODO SEGURO ====" -ForegroundColor Yellow
        Write-Host "Dashboard iniciado en modo de compatibilidad" -ForegroundColor Gray
    }
}

# >> FUNCION: Actualizar campos dinamicos del dashboard
function Update-DynamicFields {
    try {
        # Obtener datos dinamicos con validacion
        $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $osVersion = if ([string]::IsNullOrEmpty($script:osVersionString)) { 
            "Windows " + [System.Environment]::OSVersion.Version.ToString() 
        }
        else { 
            $script:osVersionString 
        }
    
        # --- Informacion del Hotspot ---
        $hotspotStatus = "[OFF] Inactivo"
        $script:hotspotActive = $false
        $connectedClients = "0"
        try {
            $hostedNetworkOutput = netsh wlan show hostednetwork | Out-String
            if ($hostedNetworkOutput -match '(Status|Estado)\s*:\s*(\w+)') {
                if ($matches[2] -in @("Started", "Iniciado")) {
                    $hotspotStatus = "[ON] Activo"
                    $script:hotspotActive = $true
                }
            }
            $clientsLine = $hostedNetworkOutput | Select-String -Pattern "(Number of clients|Número de clientes conectados)"
            if ($clientsLine -match '(\d+)$') {
                $connectedClients = $matches[1]
            }
        }
        catch {
            $hotspotStatus = "[?] Desconocido"
        }
    
        # Estadisticas de trafico con velocidades en tiempo real
        $internetInterface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1
        $trafficStats = if ($internetInterface) {
            $stats = Get-NetAdapterStatistics -Name $internetInterface.InterfaceAlias -ErrorAction SilentlyContinue
            if ($stats) {
                $sent = if ($stats.SentBytes -gt 1GB) { "{0:N2} GB" -f ($stats.SentBytes / 1GB) } else { "{0:N2} MB" -f ($stats.SentBytes / 1MB) }
                $received = if ($stats.ReceivedBytes -gt 1GB) { "{0:N2} GB" -f ($stats.ReceivedBytes / 1GB) } else { "{0:N2} MB" -f ($stats.ReceivedBytes / 1MB) }
                $speedInfo = "UP: $($script:currentUploadSpeed) KB/s | DOWN: $($script:currentDownloadSpeed) KB/s"
                "$speedInfo | Total: UP $sent/DOWN $received"
            }
            else { "No disponible" }
        }
        else { "No disponible" }        # Calculos de disponibilidad
        $totalUptime = ([datetime]::Now - $script:startTime)
        $totalDowntimeSeconds = $script:totalDowntimeStopwatch.Elapsed.TotalSeconds
        $availabilityPercentage = if ($totalUptime.TotalSeconds -gt 0) {
            (($totalUptime.TotalSeconds - $totalDowntimeSeconds) / $totalUptime.TotalSeconds) * 100
        }
        else {
            100
        }
        $availabilityColor = if ($availabilityPercentage -ge 99) { "Green" } elseif ($availabilityPercentage -ge 95) { "Yellow" } else { "Red" }
        $availabilityBar = Get-Bar -Value $availabilityPercentage -MaxValue 100 -Width 20 -Color $availabilityColor
        $availabilityStatus = "$($availabilityPercentage.ToString('N2'))% $availabilityBar"

        # Indicadores de calidad
        $latencyValue = $script:currentLatency
        $latencyColor = if ($latencyValue -eq 0) { "Red" } elseif ($latencyValue -le 50) { "Green" } elseif ($latencyValue -le 100) { "Yellow" } else { "Red" }
        $latencyBar = Get-Bar -Value $latencyValue -MaxValue 200 -Width 20 -Color $latencyColor
        $latencyStatus = "$($latencyValue.ToString('F0'))ms $latencyBar"

        $jitterValue = $script:currentJitter
        $jitterColor = if ($jitterValue -eq 0) { "White" } elseif ($jitterValue -le 10) { "Green" } elseif ($jitterValue -le 30) { "Yellow" } else { "Red" }
        $jitterBar = Get-Bar -Value $jitterValue -MaxValue 50 -Width 20 -Color $jitterColor
        $jitterStatus = "$($jitterValue.ToString('F1'))ms $jitterBar"

        $packetLossValue = $script:packetLoss
        $packetLossColor = if ($packetLossValue -eq 0) { "Green" } elseif ($packetLossValue -le 5) { "Yellow" } else { "Red" }
        $packetLossBar = Get-Bar -Value $packetLossValue -MaxValue 100 -Width 20 -Color $packetLossColor
        $packetLossStatus = "$($packetLossValue.ToString('F1'))% $packetLossBar"

        # Historial grafico mejorado con estabilidad
        $historyGraph = ""
        if ($script:performanceHistory.Count -ge 3) {
            $recent = $script:performanceHistory | Select-Object -Last 15
            foreach ($measurement in $recent) {
                $indicator = if ($measurement.Latency -eq 0) { "X" }
                elseif ($measurement.Latency -le 30 -and $measurement.PacketLoss -eq 0) { "=" }  # Excelente
                elseif ($measurement.Latency -le 50 -and $measurement.PacketLoss -le 1) { "+" }  # Bueno
                elseif ($measurement.Latency -le 100 -and $measurement.PacketLoss -le 5) { "-" } # Regular
                elseif ($measurement.Latency -le 150) { "." }                                    # Malo
                else { "!" }                                                                    # Critico
                $historyGraph += $indicator
            }
            $historyGraph += " | Estabilidad: $($script:connectionStability)"
        }
        else {
            $historyGraph = "Inicializando sistema de monitoreo..."
        }    # ACTUALIZAR CAMPOS DINAMICOS CON NUEVA ESTRUCTURA
        # Linea 4: Tiempo y sistema
        Write-PaddedField -Line 3 -Column 8 -Value $currentTime -Width 22 -Color "Yellow"
        Write-PaddedField -Line 3 -Column 41 -Value $osVersion -Width 40 -Color "Gray"
    
        # Linea 8: Hotspot
        Write-PaddedField -Line 7 -Column 9 -Value $hotspotStatus -Width 17 -Color "White"
        Write-PaddedField -Line 7 -Column 35 -Value $SSID -Width 20 -Color "Yellow"
        Write-PaddedField -Line 7 -Column 67 -Value $connectedClients -Width 3 -Color "Green"    
        # Linea 12-14: Conexion
        Write-PaddedField -Line 11 -Column 8 -Value $script:connectionType -Width 20 -Color "White"
        Write-PaddedField -Line 11 -Column 42 -Value $script:networkSpeed -Width 20 -Color "Yellow"
        Write-PaddedField -Line 12 -Column 13 -Value $script:lastIpAddress -Width 18 -Color "Cyan"
        Write-PaddedField -Line 12 -Column 41 -Value $script:optimalDNS -Width 25 -Color "Green"
        Write-PaddedField -Line 13 -Column 12 -Value $script:adapterId -Width 58 -Color "White"
    
        # Linea 18-21: Rendimiento (cada metrica en su propia linea)
        Write-PaddedField -Line 17 -Column 11 -Value $latencyStatus -Width 58 -Color $latencyColor
        Write-PaddedField -Line 18 -Column 9 -Value $jitterStatus -Width 60 -Color $jitterColor
        Write-PaddedField -Line 19 -Column 11 -Value $packetLossStatus -Width 58 -Color $packetLossColor
        Write-PaddedField -Line 20 -Column 10 -Value $trafficStats -Width 59 -Color "White"    
        # Linea 25-27: Estabilidad
        Write-PaddedField -Line 24 -Column 17 -Value $availabilityStatus -Width 53 -Color $availabilityColor
        Write-PaddedField -Line 25 -Column 15 -Value $script:reconnectionCount -Width 55 -Color "Red"
        Write-PaddedField -Line 26 -Column 16 -Value ("{0:dd'd 'hh'h 'mm'm 'ss's'}" -f $totalUptime) -Width 54 -Color "Green"
    
        # Linea 31-32: Estado operativo
        Write-PaddedField -Line 30 -Column 9 -Value $script:currentAction -Width 61 -Color "White"
        Write-PaddedField -Line 31 -Column 12 -Value $historyGraph -Width 58 -Color "Gray"
    
    }
    catch {
        Add-LogMessage -Message "[ERROR] Error actualizando dashboard: $($_.Exception.Message)"
        # Fallback con datos basicos
        Write-PaddedField -Line 3 -Column 8 -Value $currentTime -Width 22 -Color "Red"
        Write-PaddedField -Line 30 -Column 9 -Value "[ERROR] Error en dashboard" -Width 61 -Color "Red"
    }
}

# >> FUNCION: Actualizar zona de log mejorada
function Update-LogArea {
    try {
        # Agregar metricas del sistema al log si hay espacio
        if ($script:logMessages.Count -lt 6) {
            Add-LogMessage -Message "SYS: CPU:$($script:cpuUsage)% RAM:$($script:memoryUsage)% DISK:$($script:diskUsage)% SCORE:$($script:performanceScore)"
        }
        
        # Limpiar y actualizar area de log (lineas 36-43 del nuevo dashboard)
        for ($i = 0; $i -lt 8; $i++) {
            $lineIndex = 35 + $i  # Empezar en linea 36 (dashboard termina en linea 34)
            Set-CursorPosition -X 1 -Y $lineIndex
            
            if ($i -lt $script:logMessages.Count) {
                $message = $script:logMessages[$i]
                $truncatedMessage = if ($message.Length -gt 68) { $message.Substring(0, 65) + "..." } else { $message }
                
                # Colorear mensajes segun tipo
                $color = "Gray"
                if ($message -match "\[ERROR\]") { $color = "Red" }
                elseif ($message -match "\[WARN\]") { $color = "Yellow" }  
                elseif ($message -match "\[OK\]") { $color = "Green" }
                elseif ($message -match "SYS:") { $color = "Cyan" }
                
                Write-Host " $($truncatedMessage.PadRight(69))" -ForegroundColor $color -NoNewline
            }
            else {
                Write-Host (" " * 70) -NoNewline
            }
        }
        
        # Posicionar cursor al final para evitar interferencias
        Set-CursorPosition -X 0 -Y 45
    }
    catch {
        # Fallback silencioso para evitar errores en cascada
    }
}

function Test-InternetConnection {
    param(
        [string]$HostAddress
    )
    return Test-Connection -ComputerName $HostAddress -Count 1 -Quiet -ErrorAction SilentlyContinue
}

# >> FUNCION NUEVA: Obtener IP externa
function Get-ExternalIp {
    try {
        # Usar un servicio rapido y confiable con timeout corto
        return (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 2 -ErrorAction Stop).Trim()
    }
    catch {
        # Fallback a un segundo servicio
        try {
            return (Invoke-RestMethod -Uri "https://ipinfo.io/ip" -TimeoutSec 2 -ErrorAction Stop).Trim()
        }
        catch {
            # Fallback a un tercer servicio
            try {
                return (Invoke-RestMethod -Uri "https://icanhazip.com" -TimeoutSec 2 -ErrorAction Stop).Trim()
            }
            catch {
                return "No disponible" 
            }
        }
    }
}

# >> FUNCION MEJORADA: Reinicio inteligente de adaptadores
function Restart-InternetAdapter {
    Set-CurrentAction "[SEARCH] Identificando adaptador de red principal..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard
    Show-Spinner -Message "Reiniciando adaptador..." -DurationSeconds 5
    
    $internetInterface = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1
    if ($internetInterface) {
        $adapterName = $internetInterface.NetAdapter.Name
        Set-CurrentAction "[REFRESH] Reiniciando adaptador '$adapterName'..."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        
        try {
            # Flush DNS cache
            Write-Log -Message "Limpiando cache DNS (flushdns)."
            ipconfig /flushdns | Out-Null
            
            # Reiniciar adaptador con metodo seguro
            Write-Log -Message "Deshabilitando adaptador '$adapterName'."
            Disable-NetAdapter -Name $adapterName -Confirm:$false -ErrorAction Stop
            Start-Sleep -Seconds 3
            Write-Log -Message "Habilitando adaptador '$adapterName'."
            Enable-NetAdapter -Name $adapterName -ErrorAction Stop
            Start-Sleep -Seconds 5
            
            # Renovar configuracion IP
            Write-Log -Message "Liberando IP (release)."
            ipconfig /release | Out-Null
            Start-Sleep -Seconds 2
            Write-Log -Message "Renovando IP (renew)."
            ipconfig /renew | Out-Null
            
            $script:currentAction = "[OK] Adaptador $adapterName reiniciado. Verificando..."
            Write-Log -Message $script:currentAction
        }
        catch {
            $errorMessage = "Error al reiniciar adaptador $adapterName : $($_.Exception.Message)"
            $script:currentAction = "[ERROR] $errorMessage"
            Write-Log -Message $errorMessage -Level "ERROR"
        }
        Show-PremiumDashboard
    }
    else {
        $script:currentAction = "[ERROR] No se encontro un adaptador de red con gateway."
        Write-Log -Message $script:currentAction -Level "WARN"
        Show-PremiumDashboard
        Start-Sleep -Seconds 5
    }
}

# >> FUNCION MODERNIZADA: Configuracion de hotspot mejorada
function Start-Hotspot {
    $script:currentAction = "[SETUP] Configurando el Hotspot (SSID: $SSID)..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard
    Show-Spinner -Message "Configurando Hotspot..." -DurationSeconds 4
    
    try {
        # Detener hotspot existente si esta activo
        Write-Log -Message "Intentando detener cualquier red hospedada existente."
        netsh wlan stop hostednetwork 2>$null | Out-Null
        Start-Sleep -Seconds 2
        
        # Configurar nuevo hotspot
        Write-Log -Message "Configurando nueva red hospedada: $SSID"
        netsh wlan set hostednetwork mode=allow ssid=$SSID key=$Password keyUsage=persistent | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "No se pudo ejecutar 'netsh wlan set hostednetwork'." }

        $script:currentAction = "[START] Iniciando red hospedada..."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        
        netsh wlan start hostednetwork | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $script:currentAction = "[WARN] Advertencia: Hotspot configurado pero no se pudo iniciar"
            Write-Log -Message $script:currentAction -Level "WARN"
        }
        else {
            $script:currentAction = "[OK] Hotspot configurado e iniciado exitosamente"
            Write-Log -Message $script:currentAction
            $script:hotspotActive = $true
        }
        
        Show-PremiumDashboard
        Start-Sleep -Seconds 3
        
        # Intentar compartir conexion de Internet
        $script:currentAction = "[SHARE] Configurando compartir Internet (ICS)..."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        
        $internetAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike "*Hosted Network*" -and ($_.Name -notlike "*Loopback*") } | Select-Object -First 1
        
        if ($internetAdapter) {
            $script:currentAction = "[NET] Compartiendo conexion desde $($internetAdapter.Name)..."
            Write-Log -Message $script:currentAction
            Show-PremiumDashboard
            
            try {
                # Metodo alternativo mas confiable para compartir Internet
                $netShare = New-Object -ComObject HNetCfg.HNetShare -ErrorAction Stop
                $connections = $netShare.EnumEveryConnection
                
                foreach ($connection in $connections) {
                    $props = $netShare.NetConnectionProps.Invoke($connection)
                    if ($props.Name -eq $internetAdapter.Name) {
                        $config = $netShare.INetSharingConfigurationForINetConnection.Invoke($connection)
                        if (-not $config.SharingEnabled) {
                            $config.EnableSharing(0) # 0 = public, 1 = private
                            $script:currentAction = "[OK] Compartir Internet habilitado"
                            Write-Log -Message "$($script:currentAction) para '$($internetAdapter.Name)'."
                        }
                        else {
                            $script:currentAction = "[INFO] Compartir Internet ya estaba habilitado"
                            Write-Log -Message "$($script:currentAction) para '$($internetAdapter.Name)'."
                        }
                        break
                    }
                }
            }
            catch {
                $logMessage = "Fallo el metodo COM para ICS. Fallback. Error: $($_.Exception.Message)"
                Write-Log -Message $logMessage -Level "WARN"
                $script:currentAction = "[WARN] Compartir Internet: No se pudo usar el metodo COM. Usando fallback..."
                Show-PremiumDashboard
                Start-Sleep -Seconds 1
                
                # Fallback: buscar el adaptador del hotspot y configurar ICS manualmente
                $hostedNetworkAdapter = Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "*Hosted Network Virtual Adapter*" } | Select-Object -First 1
                if ($hostedNetworkAdapter) {
                    $script:currentAction = "[SHARE] Configurando IP en adaptador de Hotspot: $($hostedNetworkAdapter.Name)..."
                    Write-Log -Message $script:currentAction
                    Show-PremiumDashboard
                    netsh interface ip set address name="$($hostedNetworkAdapter.Name)" static 192.168.137.1 255.255.255.0 | Out-Null
                }
                else {
                    $script:currentAction = "[ERROR] No se pudo encontrar el adaptador de Hotspot para el fallback de ICS."
                    Write-Log -Message $script:currentAction -Level "ERROR"
                }
            }
        }
        else {
            $script:currentAction = "[ERROR] No se encontro adaptador para compartir Internet."
            Write-Log -Message $script:currentAction -Level "WARN"
        }
        
        Show-PremiumDashboard
        Start-Sleep -Seconds 2
        
    }
    catch {
        $errorMessage = "Error critico en la configuracion del Hotspot: $($_.Exception.Message)"
        $script:currentAction = "[CRITICAL] $errorMessage"
        Write-Log -Message $errorMessage -Level "FATAL"
        Show-PremiumDashboard
        Start-Sleep -Seconds 5
    }
}

# >> FUNCION NUEVA: Optimizaciones de red para Windows
function Optimize-NetworkSettings {
    if ($script:systemOptimized) { return }
    
    $script:currentAction = "[OPTIMIZE] Optimizando configuraciones de red..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard
    
    try {
        # Optimizar configuraciones TCP/IP
        Write-Log -Message "Aplicando optimizaciones TCP/IP globales."
        netsh int tcp set global autotuninglevel=normal | Out-Null
        netsh int tcp set global chimney=enabled | Out-Null
        netsh int tcp set global rss=enabled | Out-Null
        netsh int tcp set global netdma=enabled | Out-Null

        # Optimizar el propio adaptador de red
        Optimize-NetworkAdapterAdvanced
        
        # Configurar DNS optimo
        Set-FastestDNS
        
        $script:systemOptimized = $true
        $script:currentAction = "[OK] Sistema optimizado para mejor rendimiento de red"
        Write-Log -Message "Optimizacion de red inicial completada exitosamente." -Level "INFO"        
    }
    catch {
        $errorMessage = "Una o mas optimizaciones de red fallaron. Error: $($_.Exception.Message)"
        $script:currentAction = "[PARTIAL] Optimizacion parcial completada"
        Write-Log -Message $errorMessage -Level "WARN"
    }
    
    Show-PremiumDashboard
    Start-Sleep -Seconds 2
}

# >> FUNCION NUEVA: Optimizacion avanzada de adaptador de red
function Optimize-NetworkAdapterAdvanced {
    $script:currentAction = "[BOOST] Optimizando adaptador a bajo nivel..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard
    Start-Sleep -Seconds 1

    $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike "*Hosted Network*" } | Select-Object -First 1
    if (-not $activeAdapter) {
        $script:currentAction = "[WARN] No se encontro adaptador activo para optimizacion avanzada."
        Write-Log -Message $script:currentAction -Level "WARN"
        Show-PremiumDashboard
        Start-Sleep -Seconds 2
        return
    }
    
    $adapterName = $activeAdapter.Name
    $script:currentAction = "[BOOST] Aplicando perfiles de alto rendimiento a '$adapterName'..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard
    
    # Deshabilitar ahorro de energia de forma agresiva
    try {
        Set-NetAdapterPowerManagement -Name $adapterName -ArpOffload "Disabled" -D0PacketCoalescing "Disabled" -DeviceSleepOnDisconnect "Disabled" -NSOffload "Disabled" -RsnRekeyOffload "Disabled" -WakeOnMagicPacket "Disabled" -WakeOnPattern "Disabled" -ErrorAction Stop | Out-Null
        $script:currentAction = "[BOOST] Perfil de energia de red ajustado a MAXIMO rendimiento."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Log -Message "No se pudieron ajustar todas las opciones de energía del adaptador '$adapterName'." -Level "WARN"
    }

    # Habilitar optimizaciones de rendimiento de CPU
    try {
        Set-NetAdapterRss -Name $adapterName -Enabled $true -ErrorAction Stop | Out-Null
        Set-NetAdapterLso -Name $adapterName -Enabled $true -ErrorAction Stop | Out-Null
        $script:currentAction = "[BOOST] Offloading de CPU y RSS habilitados."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Log -Message "No se pudieron habilitar RSS o LSO en el adaptador '$adapterName'." -Level "WARN"
    }
    
    $script:currentAction = "[OK] Optimizaciones avanzadas de adaptador aplicadas."
    Show-PremiumDashboard
    Start-Sleep -Seconds 2
}

# >> FUNCION NUEVA: Gestion algoritmica de DNS
function Set-FastestDNS {
    $script:currentAction = "[DNS-OPT] Buscando el DNS mas rapido..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard

    $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike "*Hosted Network*" } | Select-Object -First 1
    if (-not $activeAdapter) {
        $script:currentAction = "[WARN] No se encontro adaptador para optimizar DNS."
        Write-Log -Message $script:currentAction -Level "WARN"
        Show-PremiumDashboard
        Start-Sleep -Seconds 2
        return
    }

    $dnsServers = @(
        @{Address = "8.8.8.8"; Name = "Google" },
        @{Address = "1.1.1.1"; Name = "Cloudflare" },
        @{Address = "208.67.222.222"; Name = "OpenDNS" }
    )
    
    $dnsTimings = foreach ($dns in $dnsServers) {
        $ping = Test-Connection -ComputerName $dns.Address -Count 2 -ErrorAction SilentlyContinue
        if ($ping) {
            $avgTime = ($ping | Measure-Object -Property ResponseTime -Average).Average
            if ($avgTime -gt 0) {
                @{ Address = $dns.Address; Time = $avgTime }
            }
        }
    }
    
    if ($dnsTimings) {
        $sortedDNS = $dnsTimings | Sort-Object Time
        $fastestDNS = $sortedDNS[0]
        $secondFastestDNS = if ($sortedDNS.Count -gt 1) { $sortedDNS[1].Address } else { "8.8.4.4" } # Fallback DNS secundario
        
        if ($fastestDNS.Address -ne $script:optimalDNS) {
            $script:currentAction = "[DNS-OPT] Cambiando a DNS mas rapido: $($fastestDNS.Address)"
            Write-Log -Message "$($script:currentAction). Secundario: $secondFastestDNS"
            Show-PremiumDashboard
            Set-DnsClientServerAddress -InterfaceAlias $activeAdapter.Name -ServerAddresses $fastestDNS.Address, $secondFastestDNS -ErrorAction SilentlyContinue
            $script:optimalDNS = $fastestDNS.Address
        }
        else {
            $script:currentAction = "[DNS-OPT] El DNS actual ya es el mas rapido."
            Write-Log -Message $script:currentAction
            Show-PremiumDashboard
        }
    }
    Start-Sleep -Seconds 1
}

# >> FUNCION NUEVA: Logica de Mejora Continua Algoritmica
function Invoke-AdaptiveRecovery {
    $script:currentAction = "[ADAPT] Iniciando recuperacion adaptativa..."
    Write-Log -Message $script:currentAction -Level "WARN"
    Show-PremiumDashboard
    Start-Sleep -Seconds 1

    # Nivel 1: Jitter alto o perdida de paquetes moderada. Suele ser un problema de cache.
    if ($script:currentJitter -gt $JitterThreshold -or ($script:packetLoss -gt 1 -and $script:packetLoss -le 10) ) {
        $script:currentAction = "[ADAPT-1] Jitter/Perdida detectado. Limpiando cache DNS..."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        ipconfig /flushdns | Out-Null
        Start-Sleep -Seconds 2
        return
    }

    # Nivel 2: Latencia alta persistente. El DNS actual puede estar congestionado.
    if ($script:currentLatency -gt $LatencyThreshold) {
        $script:currentAction = "[ADAPT-2] Latencia alta detectada. Re-optimizando DNS..."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        Set-FastestDNS
        return
    }
}

# >> FUNCION NUEVA: Monitor de velocidades de red en tiempo real
function Monitor-NetworkSpeeds {
    try {
        # Obtener estadisticas de red actual
        $networkAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*" } | Select-Object -First 1
        
        if ($networkAdapter) {
            $stats = Get-NetAdapterStatistics -Name $networkAdapter.Name -ErrorAction SilentlyContinue
            
            if ($stats) {
                $currentTime = Get-Date
                
                # Calcular velocidades si tenemos datos previos
                if ($script:lastNetworkStats -and $script:lastStatsTime) {
                    $timeDiff = ($currentTime - $script:lastStatsTime).TotalSeconds
                    
                    if ($timeDiff -gt 0) {
                        $bytesSentDiff = $stats.SentBytes - $script:lastNetworkStats.SentBytes
                        $bytesReceivedDiff = $stats.ReceivedBytes - $script:lastNetworkStats.ReceivedBytes
                        
                        # Convertir a KB/s
                        $script:currentUploadSpeed = [math]::Round(($bytesSentDiff / $timeDiff) / 1024, 2)
                        $script:currentDownloadSpeed = [math]::Round(($bytesReceivedDiff / $timeDiff) / 1024, 2)
                        
                        # Actualizar totales
                        $script:totalBytesSent = $stats.SentBytes
                        $script:totalBytesReceived = $stats.ReceivedBytes
                    }
                }
                
                # Guardar para proxima medicion
                $script:lastNetworkStats = $stats
                $script:lastStatsTime = $currentTime
            }
        }
    }
    catch {
        Add-LogMessage -Message "[ERROR] Monitor-NetworkSpeeds: $($_.Exception.Message)"
    }
}

# >> FUNCION NUEVA: Monitor avanzado de estabilidad de conexion
function Test-ConnectionStability {
    try {
        $script:connectionStability = "Estable"
        
        # Test de ping multiple para detectar inestabilidad
        $pingResults = @()
        for ($i = 0; $i -lt 10; $i++) {
            $ping = Test-Connection -ComputerName $script:optimalDNS -Count 1 -ErrorAction SilentlyContinue
            if ($ping) {
                $pingResults += $ping.ResponseTime
            }
            else {
                $pingResults += 999
            }
            Start-Sleep -Milliseconds 100
        }
        
        # Analizar variabilidad
        $avgPing = ($pingResults | Measure-Object -Average).Average
        $maxPing = ($pingResults | Measure-Object -Maximum).Maximum
        $variance = $pingResults | ForEach-Object { [Math]::Pow(($_ - $avgPing), 2) }
        $stdDev = [Math]::Sqrt(($variance | Measure-Object -Sum).Sum / $variance.Count)
        
        # Determinar estabilidad
        if ($stdDev -gt 50 -or $maxPing -gt 500) {
            $script:connectionStability = "Inestable"
            return $false
        }
        elseif ($stdDev -gt 20 -or $maxPing -gt 200) {
            $script:connectionStability = "Moderada"
            return $true
        }
        else {
            $script:connectionStability = "Estable"
            return $true
        }
    }
    catch {
        $script:connectionStability = "Error"
        return $false
    }
}

# >> FUNCION NUEVA: Auto-correccion de desconexiones intermitentes
function Repair-IntermittentConnection {
    Add-LogMessage -Message "[REPAIR] Detectada conexion intermitente - Iniciando reparacion"
    
    try {
        # Step 1: Flush DNS cache
        ipconfig /flushdns | Out-Null
        Add-LogMessage -Message "[REPAIR] Cache DNS limpiado"
        
        # Step 2: Reset Winsock
        netsh winsock reset | Out-Null
        Add-LogMessage -Message "[REPAIR] Winsock reiniciado"
        
        # Step 3: Reset TCP/IP stack
        netsh int ip reset | Out-Null
        Add-LogMessage -Message "[REPAIR] Stack TCP/IP reiniciado"
        
        # Step 4: Release and renew IP
        ipconfig /release | Out-Null
        Start-Sleep -Seconds 2
        ipconfig /renew | Out-Null
        Add-LogMessage -Message "[REPAIR] IP renovada"
        
        # Step 5: Re-optimize network settings
        Set-FastestDNS
        
        $script:lastOptimizationTime = [datetime]::Now
        $script:optimizationCount++
        
        Add-LogMessage -Message "[OK] Reparacion de conexion completada"
        return $true
    }
    catch {
        Add-LogMessage -Message "[ERROR] Error en reparacion: $($_.Exception.Message)"
        return $false
    }
}

# >> FUNCION NUEVA: Optimizaciones TCP/IP para estabilidad
function Optimize-TCPIPSettings {
    Add-LogMessage -Message "[TCP] Optimizando configuraciones TCP/IP para estabilidad"
    
    try {
        # Optimizar configuraciones de TCP
        netsh int tcp set global autotuninglevel=normal | Out-Null
        netsh int tcp set global chimney=enabled | Out-Null
        netsh int tcp set global rss=enabled | Out-Null
        netsh int tcp set global netdma=enabled | Out-Null
        
        # Configurar timeouts optimizados
        netsh int tcp set global initialrto=3000 | Out-Null
        
        # Habilitar window scaling
        netsh int tcp set global windowscaling=enable | Out-Null
        
        Add-LogMessage -Message "[OK] Configuraciones TCP/IP optimizadas"
        return $true
    }
    catch {
        Add-LogMessage -Message "[WARN] Error optimizando TCP/IP: $($_.Exception.Message)"
        return $false
    }
}

# >> FUNCION NUEVA: Sistema de deteccion y recuperacion de caidas
function Monitor-ConnectionDrops {
    # Detectar caidas de conexion basado en historial
    if ($script:performanceHistory.Count -ge 5) {
        $recentFailures = ($script:performanceHistory[-5..-1] | Where-Object { $_.PacketLoss -gt 50 }).Count
        
        if ($recentFailures -ge 3) {
            Add-LogMessage -Message "[ALERT] Multiple caidas detectadas - Iniciando recuperacion"
            
            # Estrategia de recuperacion progresiva
            if ($script:optimizationCount -eq 0) {
                Repair-IntermittentConnection
            }
            elseif ($script:optimizationCount -eq 1) {
                Optimize-TCPIPSettings
                Set-FastestDNS
            }
            else {
                # Recuperacion mas agresiva
                Restart-InternetAdapter
            }
        }
    }
}
function Set-IntelligentQoS {
    $script:currentAction = "[QOS] Configurando Calidad de Servicio Inteligente..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard
    
    # Limpiar politicas previas para evitar conflictos
    $policyNames = @("OptiGemini_HighPriority_*", "OptiGemini_MediumPriority_*")
    foreach ($policyPattern in $policyNames) {
        $existingPolicies = Get-NetQosPolicy | Where-Object { $_.Name -like $policyPattern }
        foreach ($policy in $existingPolicies) {
            $script:currentAction = "[QOS] Eliminando politica antigua: $($policy.Name)..."
            Write-Log -Message $script:currentAction
            Show-PremiumDashboard
            Remove-NetQosPolicy -Name $policy.Name -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
    Start-Sleep -Seconds 1
    
    $script:currentAction = "[QOS] Creando nuevas politicas de priorizacion..."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard

    # Prioridad MAXIMA (EF - 46) para juegos, VoIP, y comunicaciones en tiempo real
    $highPrioApps = @(
        "valorant.exe", "LeagueofLegends.exe", "csgo.exe", 
        "FortniteClient-Win64-Shipping.exe", "zoom.exe", 
        "discord.exe", "slack.exe", "msteams.exe"
    )
    
    $successCount = 0
    foreach ($app in $highPrioApps) {
        try {
            $policyName = "OptiGemini_HighPriority_$($app.Replace('.exe', ''))"
            New-NetQosPolicy -Name $policyName -AppPathNameMatchCondition $app -DSCPAction 46 -ErrorAction Stop | Out-Null
            $successCount++
        }
        catch {
            Write-Log -Message "No se pudo crear politica QoS para $app. Error: $_" -Level "WARN"
        }
    }
    
    if ($successCount -gt 0) {
        $script:currentAction = "[QOS] $successCount politicas de alta prioridad creadas."
        Write-Log -Message $script:currentAction
        Show-PremiumDashboard
        Start-Sleep -Seconds 1
    }

    # Prioridad ALTA (AF41 - 34) para streaming de video
    $mediumPrioApps = @("netflix.exe")
    
    foreach ($app in $mediumPrioApps) {
        try {
            $policyName = "OptiGemini_MediumPriority_$($app.Replace('.exe', ''))"
            New-NetQosPolicy -Name $policyName -AppPathNameMatchCondition $app -DSCPAction 34 -ErrorAction Stop | Out-Null
            $script:currentAction = "[QOS] Politica de streaming creada para $app."
            Write-Log -Message $script:currentAction
        }
        catch {
            Write-Log -Message "No se pudo crear politica QoS para $app. Error: $_" -Level "WARN"
        }
    }
    
    $script:currentAction = "[OK] Politicas de QoS inteligentes aplicadas."
    Write-Log -Message $script:currentAction
    Show-PremiumDashboard
    Start-Sleep -Seconds 2
}

# >> FUNCION NUEVA: Optimizacion de buffer de red para throughput
function Optimize-NetworkBuffers {
    Add-LogMessage -Message "[BUFFER] Optimizando buffers de red para maxima velocidad"
    
    try {
        $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike "*Hosted Network*" } | Select-Object -First 1
        if ($activeAdapter) {
            # Optimizar buffers de recepcion y transmision
            Set-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "ReceiveBuffers" -RegistryValue 2048 -ErrorAction SilentlyContinue
            Set-NetAdapterAdvancedProperty -Name $activeAdapter.Name -RegistryKeyword "TransmitBuffers" -RegistryValue 2048 -ErrorAction SilentlyContinue
            
            Add-LogMessage -Message "[OK] Buffers de red optimizados para throughput"
        }
    }
    catch {
        Add-LogMessage -Message "[WARN] Error optimizando buffers: $($_.Exception.Message)"
    }
}

# >> FUNCION NUEVA: Ajuste automatico de MTU
function Optimize-MTUSize {
    Add-LogMessage -Message "[MTU] Detectando y configurando MTU optimo"
    
    try {
        # Test common MTU sizes
        $mtuSizes = @(1500, 1472, 1464, 1452, 1432, 1400)
        $optimalMTU = 1500
        
        foreach ($mtu in $mtuSizes) {
            $pingResult = ping $script:optimalDNS -f -l ($mtu - 28) -n 1
            if ($pingResult -match "Reply from") {
                $optimalMTU = $mtu
                break
            }
        }
        
        # Configurar MTU optimo en la interfaz activa
        $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike "*Hosted Network*" } | Select-Object -First 1
        if ($activeAdapter) {
            netsh interface ipv4 set subinterface $activeAdapter.InterfaceIndex mtu=$optimalMTU store=persistent | Out-Null
            Add-LogMessage -Message "[OK] MTU configurado a $optimalMTU para maxima eficiencia"
        }
        
        return $optimalMTU
    }
    catch {
        Add-LogMessage -Message "[WARN] Error configurando MTU: $($_.Exception.Message)"
        return 1500
    }
}

#endregion

#=======================================================================================
#                               BUCLE PRINCIPAL PREMIUM
#=======================================================================================
try {
    # Mostrar splash inicial
    Clear-Host
    Write-Host "=" -ForegroundColor Cyan -NoNewline
    Write-Host ("=" * 87) -ForegroundColor Cyan
    Write-Host "|" -NoNewline -ForegroundColor Cyan
    Write-Host "              [ROCKET] INICIANDO OPTIGEMINI v2.2 PREMIUM              " -NoNewline -ForegroundColor White
    Write-Host "|" -ForegroundColor Cyan
    Write-Host "|" -NoNewline -ForegroundColor Cyan
    Write-Host "              Sistema de Optimizacion de Red Avanzado                " -NoNewline -ForegroundColor Gray
    Write-Host "|" -ForegroundColor Cyan
    Write-Host "=" -ForegroundColor Cyan -NoNewline
    Write-Host ('=' * 87) -ForegroundColor Cyan
    Start-Sleep -Seconds 2

    # Obtener informacion del sistema UNA SOLA VEZ para evitar parpadeo en el bucle
    try {
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($osInfo) {
            $script:osVersionString = "$($osInfo.Caption) ($($osInfo.Version))"
        }
        else {
            $script:osVersionString = "Windows"
        }
    }
    catch {
        $script:osVersionString = "Windows"
    }
    Write-Log -Message "Sistema Operativo Detectado: $($script:osVersionString)"

    # Optimizar configuraciones del sistema
    Optimize-NetworkSettings
    
    # Configurar Calidad de Servicio (QoS)
    Set-IntelligentQoS
    
    # Nuevas optimizaciones para estabilidad y velocidad
    Optimize-TCPIPSettings
    Optimize-NetworkBuffers  
    Optimize-MTUSize
    
    # NOTA: El hotspot se activara manualmente por el usuario
    Add-LogMessage -Message "[INFO] Hotspot disponible para activacion manual"

    $logMessage = "Iniciando el bucle principal de monitoreo sin hotspot automatico."
    Write-Log -Message $logMessage
    
    # Inicializar dashboard estatico
    Set-CurrentAction "[READY] Sistema listo - Hotspot manual | Monitoreo activo..."
    Show-PremiumDashboard "ForceRefresh"
    
    # Bucle principal de monitoreo con estabilidad mejorada
    while ($true) {
        $connectionOk = $false
        $retries = 0

        # Actualizar IP externa en cada ciclo
        $script:lastIpAddress = Get-ExternalIp
        
        # Monitorear velocidades de red en tiempo real
        Monitor-NetworkSpeeds
        
        # Verificar estabilidad de conexion
        $isStable = Test-ConnectionStability
        if (-not $isStable) {
            Monitor-ConnectionDrops
        }

        # Verificacion multiple con tolerancia a fallos
        while (-not $connectionOk -and $retries -lt $MaxRetries) {
            Set-CurrentAction "[CHECK] Verificando conexion a Internet (Intento $($retries + 1)/$MaxRetries)..."
            Show-PremiumDashboard
            
            # Probar conectividad con servidor primario
            if (Test-InternetConnection -HostAddress $PrimaryCheckAddress) {
                $connectionOk = $true
                Set-CurrentAction "[STABLE] Conexion estable. Monitoreando en tiempo real..."
                
                # Si estaba caido, detener contador de downtime
                if ($script:isDown) {
                    Write-Log -Message "Conexion RESTABLECIDA. Fin del tiempo de inactividad." -Level "WARN"
                    $script:totalDowntimeStopwatch.Stop()
                    $script:isDown = $false
                }
            }
            else {
                # Intentar con servidor secundario antes de considerar fallo
                if (Test-InternetConnection -HostAddress $SecondaryCheckAddress) {
                    $connectionOk = $true
                    $script:currentAction = "[BACKUP] Conexion estable via DNS secundario..."
                    
                    if ($script:isDown) {
                        Write-Log -Message "Conexion RESTABLECIDA via DNS secundario. Fin del tiempo de inactividad." -Level "WARN"
                        $script:totalDowntimeStopwatch.Stop()
                        $script:isDown = $false
                    }
                }
                else {
                    $retries++
                    Set-CurrentAction "[RETRY] Intento $retries fallido. Reintentando en $RetryDelaySeconds segundos..."
                    Show-PremiumDashboard
                    Start-Sleep -Seconds $RetryDelaySeconds
                }
            }
        }

        # Si no se pudo establecer conexion, iniciar protocolo de recuperacion
        if (-not $connectionOk) {
            Set-CurrentAction "[ALERT] Perdida de conexion detectada! Iniciando protocolo de recuperacion..."
            Write-Log -Message $script:currentAction -Level "WARN"
            Show-PremiumDashboard
            
            # Iniciar contador de downtime si no estaba activo
            if (-not $script:isDown) {
                Write-Log -Message "Inicio de tiempo de inactividad detectado." -Level "WARN"
                $script:totalDowntimeStopwatch.Start()
                $script:isDown = $true
            }
            
            # Incrementar contador de reconexiones
            $script:reconnectionCount++
            Write-Log -Message "Incrementando contador de reconexiones a: $($script:reconnectionCount)"
            
            # Ejecutar protocolo de recuperacion
            Restart-InternetAdapter
            
            # Verificacion final post-recuperacion
            $script:currentAction = "[VERIFY] Verificacion post-recuperacion..."
            Write-Log -Message $script:currentAction
            Show-PremiumDashboard
            Start-Sleep -Seconds 3
            
            # Probar con multiples servidores para confirmar recuperacion
            $recoveryTestServers = @($PrimaryCheckAddress, $SecondaryCheckAddress, $TertiaryCheckAddress)
            $recoverySuccess = $false
            
            foreach ($testServer in $recoveryTestServers) {
                if (Test-InternetConnection -HostAddress $testServer) {
                    $recoverySuccess = $true
                    $script:currentAction = "[SUCCESS] Conexion restablecida exitosamente via $testServer!"
                    Write-Log -Message $script:currentAction -Level "INFO"
                    if ($script:isDown) {
                        $script:totalDowntimeStopwatch.Stop()
                        $script:isDown = $false
                    }
                    break
                }
            }
            
            if (-not $recoverySuccess) {
                $logMessage = "FALLO CRITICO: El protocolo de recuperacion no pudo restablecer la conexion."
                $script:currentAction = "[CRITICAL] $logMessage"
                Write-Log -Message $logMessage -Level "FATAL"
            }
        }
        else {
            # CONEXION ACTIVA: Monitorear calidad de la conexion
            if (($script:currentLatency -gt 0 -and $script:currentLatency -gt $LatencyThreshold) -or ($script:currentJitter -gt 0 -and $script:currentJitter -gt $JitterThreshold)) {
                $script:degradedConnectionCycles++
                if ($script:degradedConnectionCycles -ge 3) {
                    Invoke-AdaptiveRecovery
                    $script:degradedConnectionCycles = 0 # Reiniciar contador despues de actuar
                }
                else {
                    $script:currentAction = "[WARN] Calidad de red degradada (Ciclo $($script:degradedConnectionCycles)/3). Observando..."
                }
            }
            else {
                $script:degradedConnectionCycles = 0 # Reiniciar si la calidad es buena
            }
        }
        
        # Mostrar dashboard actualizado y esperar siguiente ciclo
        Show-PremiumDashboard
        Start-Sleep -Seconds $CheckIntervalSeconds
    }
}
catch {
    $fatalError = $_.Exception
    $logMessage = "ERROR FATAL INESPERADO en el bucle principal. Error: $($fatalError.Message). StackTrace: $($fatalError.StackTrace)"
    Write-Log -Message $logMessage -Level "FATAL" 
    Clear-Host
    Write-Host "=" -ForegroundColor Red -NoNewline
    Write-Host ("=" * 87) -ForegroundColor Red
    Write-Host "|" -NoNewline -ForegroundColor Red
    Write-Host "                        [X] ERROR INESPERADO                         " -NoNewline -ForegroundColor White
    Write-Host "|" -ForegroundColor Red
    Write-Host "|" -NoNewline -ForegroundColor Red
    Write-Host " Se ha producido un error inesperado en OptiGemini:                 " -NoNewline -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Red
    $errorMsg = $_.Exception.Message.Substring(0, [Math]::Min(65, $_.Exception.Message.Length))
    Write-Host "|" -NoNewline -ForegroundColor Red
    Write-Host " $($errorMsg.PadRight(67)) " -NoNewline -ForegroundColor White
    Write-Host "|" -ForegroundColor Red
    Write-Host "|" -NoNewline -ForegroundColor Red
    Write-Host "                                                                     " -NoNewline -ForegroundColor Red
    Write-Host "|" -ForegroundColor Red
    Write-Host "|" -NoNewline -ForegroundColor Red
    Write-Host " El script se detendra y realizara limpieza automatica.             " -NoNewline -ForegroundColor Gray
    Write-Host "|" -ForegroundColor Red
    Write-Host "=" -ForegroundColor Red -NoNewline
    Write-Host ("=" * 87) -ForegroundColor Red
    Start-Sleep -Seconds 5
}
finally {
    Write-Log -Message "Script finalizando. Ejecutando bloque finally para limpieza." -Level "SYSTEM"
    Clear-Host
    Write-Host "=" -ForegroundColor Yellow -NoNewline
    Write-Host ("=" * 87) -ForegroundColor Yellow
    Write-Host "|" -NoNewline -ForegroundColor Yellow
    Write-Host "                    [CLEANUP] LIMPIEZA Y FINALIZACION                " -NoNewline -ForegroundColor White
    Write-Host "|" -ForegroundColor Yellow
    Write-Host "|" -NoNewline -ForegroundColor Yellow
    Write-Host "                                                                     " -NoNewline -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    Write-Host "|" -NoNewline -ForegroundColor Yellow
    Write-Host " [STOP] Deteniendo el Hotspot...                                    " -NoNewline -ForegroundColor Gray
    Write-Host "|" -ForegroundColor Yellow
    
    try {
        netsh wlan stop hostednetwork | Out-Null
        Write-Host "|" -NoNewline -ForegroundColor Yellow
        Write-Host " [OK] Hotspot detenido correctamente                                " -NoNewline -ForegroundColor Green
        Write-Host "|" -ForegroundColor Yellow
        
        # Intentar deshabilitar compartir Internet
        $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike "*Hosted Network*" } | Select-Object -First 1
        if ($activeAdapter) {
            try {
                $netShare = New-Object -ComObject HNetCfg.HNetShare -ErrorAction SilentlyContinue
                $connections = $netShare.EnumEveryConnection
                foreach ($connection in $connections) {
                    $props = $netShare.NetConnectionProps.Invoke($connection)
                    if ($props.Name -eq $activeAdapter.Name) {
                        $config = $netShare.INetSharingConfigurationForINetConnection.Invoke($connection)
                        if ($config.SharingEnabled) {
                            $config.DisableSharing()
                            Write-Host "|" -NoNewline -ForegroundColor Yellow
                            Write-Host " [OK] Compartir Internet deshabilitado                              " -NoNewline -ForegroundColor Green
                            Write-Host "|" -ForegroundColor Yellow
                        }
                        break
                    }
                }
            }
            catch {
                Write-Host "|" -NoNewline -ForegroundColor Yellow
                Write-Host " [WARN] Compartir Internet: Limpieza manual requerida               " -NoNewline -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            }
        }
        
        Write-Host "|" -NoNewline -ForegroundColor Yellow
        Write-Host " [DNS] Restaurando configuraciones DNS por defecto...               " -NoNewline -ForegroundColor Gray
        Write-Host "|" -ForegroundColor Yellow
        if ($activeAdapter) {
            Set-DnsClientServerAddress -InterfaceAlias $activeAdapter.Name -ResetServerAddresses -ErrorAction SilentlyContinue
        }
        
        Write-Host "|" -NoNewline -ForegroundColor Yellow
        Write-Host " [QOS] Eliminando politicas de QoS...                               " -NoNewline -ForegroundColor Gray
        Write-Host "|" -ForegroundColor Yellow
        $qosPolicies = Get-NetQosPolicy | Where-Object { $_.Name -like "OptiGemini_*" }
        foreach ($policy in $qosPolicies) {
            Remove-NetQosPolicy -Name $policy.Name -Confirm:$false -ErrorAction SilentlyContinue
        }
        
    }
    catch {
        $errorMessage = "Error durante la limpieza final: $($_.Exception.Message)"
        Write-Host "|" -NoNewline -ForegroundColor Yellow
        Write-Host " [ERROR] Error durante la limpieza: $($errorMessage.PadRight(27)) " -NoNewline -ForegroundColor Red
        Write-Host "|" -ForegroundColor Yellow
        Write-Log -Message $errorMessage -Level "ERROR"
    }
    
    Write-Host "|" -NoNewline -ForegroundColor Yellow
    Write-Host "                                                                     " -NoNewline -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    Write-Host "|" -NoNewline -ForegroundColor Yellow
    Write-Host " [ROCKET] OptiGemini v2.2 Premium finalizado correctamente          " -NoNewline -ForegroundColor Cyan
    Write-Host "|" -ForegroundColor Yellow
    Write-Host "|" -NoNewline -ForegroundColor Yellow
    Write-Host "    Gracias por usar OptiGemini - Tu optimizador de red de confianza" -NoNewline -ForegroundColor Gray
    Write-Host "|" -ForegroundColor Yellow
    Write-Host "=" -ForegroundColor Yellow -NoNewline
    Write-Host ("=" * 87) -ForegroundColor Yellow
    
    Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}