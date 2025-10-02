function Test-InternetConnection {
    param(
        [string]$Target = '8.8.8.8'
    )

    Start-Sleep -Milliseconds (Get-Random -Minimum 20 -Maximum 80)

    [PSCustomObject]@{
        Target     = $Target
        LatencyMs  = [math]::Round((Get-Random -Minimum 15 -Maximum 45), 2)
        PacketLoss = 0
        Status     = 'Healthy'
        Timestamp  = (Get-Date).ToUniversalTime()
    }
}

function Get-NetworkMetrics {
    Start-Sleep -Milliseconds (Get-Random -Minimum 30 -Maximum 90)

    [PSCustomObject]@{
        LatencyMs     = [math]::Round((Get-Random -Minimum 20 -Maximum 60), 2)
        JitterMs      = [math]::Round((Get-Random -Minimum 1 -Maximum 5), 2)
        PacketLossPct = [math]::Round((Get-Random -Minimum 0 -Maximum 1.5), 2)
        DownloadMbps  = [math]::Round((Get-Random -Minimum 150 -Maximum 350), 2)
        UploadMbps    = [math]::Round((Get-Random -Minimum 80 -Maximum 150), 2)
        Timestamp     = (Get-Date).ToUniversalTime()
    }
}

Export-ModuleMember -Function Test-InternetConnection, Get-NetworkMetrics