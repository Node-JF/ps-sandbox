# Use -Force to ensure the latest version of your module is always loaded
Import-Module .\CoreApi.psm1 -Force

$ip = "192.168.89.253"
$user = "app"
$pass = "testtest"

$limit = 50
$delay = 10

Write-Host "Starting login/logout sequence $limit times..."

for ($i = 1; $i -le $limit; $i++) {
    Write-Host "`n--- Attempt $i of $limit ---"
    
    $session = Connect-Core -IpAddress $ip -Username $user -Password $pass
    
    if ($session.token) {
        Write-Host "Successfully logged in. Waiting $delay milliseconds..."
        Start-Sleep -Milliseconds $delay
        
        # $logout = Disconnect-Core -IpAddress $ip -Token $session.token
        # Write-Host "Logged out of session $session.token"
    }
    else {
        Write-Warning "Failed to log in: $($session.error)"
        # Uncomment the line below if you want the script to completely stop upon a failure
        # break 
    }
    
    # Wait 1 second between full cycles so you don't overwhelm the API
    Start-Sleep -Seconds 1 
}

Write-Host "`nFinished sequence."