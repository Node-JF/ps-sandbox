<#
.SYNOPSIS
    A module for authenticating with the Core API.
.DESCRIPTION
    This module provides functions to log in and log out of the Core API.
    Save this file as CoreApi.psm1
#>

# Trust all certificates (equivalent to the insecureDispatcher)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

function Connect-Core {
    <#
    .SYNOPSIS
        Logs into the Core API and retrieves an authentication token.
    .EXAMPLE
        $session = Connect-Core -IpAddress "192.168.89.253" -Username "app" -Password "testtest"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The IP address of the Core API server.")]
        [ValidateNotNullOrEmpty()]
        [string]$IpAddress,

        [Parameter(Mandatory = $true, HelpMessage = "The username for authentication.")]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(Mandatory = $true, HelpMessage = "The password for authentication.")]
        [ValidateNotNullOrEmpty()]
        [string]$Password
    )

    Write-Verbose "Logging in to core: [$IpAddress]"
    $url = "https://$IpAddress/api/v0/logon"
    
    $plainText = "${$Username}:${$Password}"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($plainText)
    $base64 = [Convert]::ToBase64String($bytes)
    
    $headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Basic $base64"
    }
    
    $body = @{
        username = $Username
        password = $Password
    } | ConvertTo-Json
    
    try {
        # prevents SSL validation errors on PowerShell Core (v6+)
        $result = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ErrorAction Stop
        return $result
    }
    catch {
        Write-Error "Error logging in to $IpAddress`: $_"
        return @{ error = $_.Exception.Message }
    }
}

function Disconnect-Core {
    <#
    .SYNOPSIS
        Logs out of the Core API using an active bearer token.
    .EXAMPLE
        Disconnect-Core -IpAddress "192.168.89.253" -Token "eyJhbGciOiJIUzI1NiIsInR5cCI6Ik..."
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The IP address of the Core API server.")]
        [ValidateNotNullOrEmpty()]
        [string]$IpAddress,

        [Parameter(Mandatory = $true, HelpMessage = "The Bearer token received from Connect-Core.")]
        [ValidateNotNullOrEmpty()]
        [string]$Token
    )

    Write-Verbose "Logging out of core: [$IpAddress]"
    $url = "https://$IpAddress/api/v0/logon"
    
    $headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $Token"
    }
    
    try {
        $result = Invoke-RestMethod -Uri $url -Method Delete -Headers $headers -ErrorAction Stop
        return $result
    }
    catch {
        Write-Error "Error logging out of $IpAddress`: $_"
        return @{ error = $_.Exception.Message }
    }
}

Export-ModuleMember -Function Connect-Core, Disconnect-Core