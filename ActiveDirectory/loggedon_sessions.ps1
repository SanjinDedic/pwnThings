$ErrorActionPreference = 'SilentlyContinue'
Write-Host "[*] Session Enumeration Script Starting..." -ForegroundColor Cyan

# Function to locate and verify PsLoggedOn
function Get-PsLoggedOnPath {
    param(
        [string]$InitialPath = "C:\Tools\PSTools\PsLoggedon.exe"
    )

    function Test-PsLoggedOnExe {
        param([string]$Path)
        
        if (-not $Path) { return $false }
        if (-not (Test-Path $Path)) { return $false }
        
        try {
            $fileInfo = Get-Item $Path
            # Verify it's an executable
            if ($fileInfo.Extension -ne ".exe") { return $false }
            
            # Test execution (capture version info)
            $result = & $Path 2>&1
            return $result -match "PsLoggedon"
        }
        catch {
            return $false
        }
    }

    function Prompt-ForPath {
        param([string]$CurrentPath)
        
        Write-Host "`n[!] PsLoggedOn not found or not working at: $CurrentPath" -ForegroundColor Yellow
        Write-Host "[?] Would you like to specify a different path? (Y/n): " -NoNewline -ForegroundColor Yellow
        $response = Read-Host
        
        if ($response -eq 'n') {
            return $null
        }
        
        do {
            Write-Host "[+] Enter the full path to PsLoggedon.exe: " -NoNewline -ForegroundColor Green
            $newPath = Read-Host
            
            if (Test-PsLoggedOnExe $newPath) {
                Write-Host "[+] Successfully verified PsLoggedOn at: $newPath" -ForegroundColor Green
                return @{
                    Path = $newPath
                    Verified = $true
                }
            }
            
            Write-Host "`n[-] Invalid path or unable to verify PsLoggedOn at: $newPath" -ForegroundColor Red
            Write-Host "[?] Would you like to try another path? (Y/n): " -NoNewline -ForegroundColor Yellow
            $retry = Read-Host
            
            if ($retry -eq 'n') {
                return $null
            }
        } while ($true)
    }

    # First try the initial path
    if (Test-PsLoggedOnExe $InitialPath) {
        return @{
            Path = $InitialPath
            Verified = $true
        }
    }

    # If initial path fails, try common locations
    $commonPaths = @(
        "C:\Tools\PSTools\PsLoggedon.exe",
        "C:\PSTools\PsLoggedon.exe",
        "C:\Windows\System32\PsLoggedon.exe",
        "${env:ProgramFiles}\PSTools\PsLoggedon.exe",
        "${env:ProgramFiles(x86)}\PSTools\PsLoggedon.exe"
    )

    foreach ($path in $commonPaths) {
        if ($path -ne $InitialPath -and (Test-PsLoggedOnExe $path)) {
            Write-Host "[+] Found PsLoggedOn at: $path" -ForegroundColor Green
            return @{
                Path = $path
                Verified = $true
            }
        }
    }

    # If no automatic detection works, prompt user
    return Prompt-ForPath $InitialPath
}

# Initialize PsLoggedOn path at script start
$psLoggedOnInfo = Get-PsLoggedOnPath
if ($null -eq $psLoggedOnInfo) {
    Write-Host "`n[-] PsLoggedOn will not be available for enumeration" -ForegroundColor Red
    $global:psLoggedOnPath = $null
    Write-Host "[!] Would you like to continue without PsLoggedOn? (Y/n): " -NoNewline -ForegroundColor Yellow
    $continue = Read-Host
    if ($continue -eq 'n') {
        Write-Host "[-] Script terminated by user" -ForegroundColor Red
        exit
    }
    Write-Host "[*] Continuing without PsLoggedOn functionality..." -ForegroundColor Yellow
} else {
    $global:psLoggedOnPath = $psLoggedOnInfo.Path
    Write-Host "[+] Using PsLoggedOn from: $psLoggedOnPath" -ForegroundColor Green
}

# Then modify your Test-PsLoggedOn function to use the global path
function Test-PsLoggedOn {
    param ($target)
    Write-Host "  [*] Testing PsLoggedOn..." -ForegroundColor Gray
    
    if (-not $global:psLoggedOnPath) {
        Write-Host "  [-] PsLoggedOn not available" -ForegroundColor Yellow
        return $false
    }
    
    $result = & $global:psLoggedOnPath \\$target 2>&1
    $resultString = $result | Out-String
    
    # Check for specific error conditions first
    if ($resultString -match "Access is denied") {
        Write-Host "  - PsLoggedOn: Access denied" -ForegroundColor Yellow
        return $false
    }
    
    # Consider it a success only if we find actual user data
    $hasLocalUsers = $resultString -match "Users logged on locally:"
    $hasResourceUsers = $resultString -match "Users logged on via resource shares:"
    
    # Check for the error but also verify if we got actual user data
    $hasRegistryError = $resultString -match "Error opening HKEY_USERS"
    
    if (($hasLocalUsers -or $hasResourceUsers) -and 
        ($resultString -match "CORP\\")) {
        Write-Host "  + PsLoggedOn: Found user sessions" -ForegroundColor Green
        return $true
    }
    
    Write-Host "  - PsLoggedOn: No valid sessions found" -ForegroundColor Red
    return $false
}

# Rest of your original script continues here...

function Test-PowerViewPath {
    param (
        [string]$Path
    )
    
    if (-not $Path) {
        Write-Host "[-] No path provided" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Path $Path)) {
        Write-Host "[-] PowerView not found at: $Path" -ForegroundColor Red
        return $false
    }
    
    try {
        # Import the script content first
        $scriptContent = Get-Content $Path -Raw
        
        # Execute the script in the current scope
        $scriptBlock = [ScriptBlock]::Create($scriptContent)
        . $scriptBlock
        
        # Test multiple PowerView commands
        $commands = @('Get-NetSession', 'Get-NetDomain', 'Get-NetUser')
        $foundCommands = 0
        
        foreach ($cmd in $commands) {
            if (Get-Command $cmd -ErrorAction SilentlyContinue) {
                $foundCommands++
            }
        }
        
        if ($foundCommands -gt 0) {
            Write-Host "[+] PowerView loaded successfully ($foundCommands commands available)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[-] PowerView commands not available after loading" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "[-] Failed to load PowerView: $_" -ForegroundColor Red
        return $false
    }
}

# Get PowerView Path
$defaultPath = "C:\Tools\PowerView.ps1"
Write-Host "`n[*] Enter path to PowerView.ps1"
Write-Host "[*] Default path is: $defaultPath"
Write-Host "[*] Press Enter to use default or input new path: " -NoNewline
$powerViewPath = Read-Host

if ([string]::IsNullOrWhiteSpace($powerViewPath)) {
    $powerViewPath = $defaultPath
}

# Test PowerView Loading
$powerViewLoaded = Test-PowerViewPath -Path $powerViewPath
if (-not $powerViewLoaded) {
    Write-Host "[!] Would you like to continue without PowerView? (y/N): " -NoNewline -ForegroundColor Yellow
    $continue = Read-Host
    if ($continue -ne 'y') {
        Write-Host "[-] Script terminated by user" -ForegroundColor Red
        exit
    }
    Write-Host "[*] Continuing without PowerView functionality..." -ForegroundColor Yellow
}

$targets = @(
    "192.168.212.74",
    "192.168.212.75",
    "192.168.212.76",
    "192.168.212.73",
    "192.168.212.72",
    "192.168.212.70"
)

Write-Host "`n[*] Loaded ${targets.Count} targets for enumeration" -ForegroundColor Cyan

function Test-NetSessionEnum {
    param ($target)
    Write-Host "  [*] Testing NetSessionEnum..." -ForegroundColor Gray
    $result = net session \\$target 2>&1
    $resultString = $result | Out-String
    
    if ($resultString -match "There are no entries in the list") {
        Write-Host "  - NetSessionEnum: No sessions found" -ForegroundColor Yellow
        return $false
    }
    elseif ($resultString -match "Access is denied") {
        Write-Host "  - NetSessionEnum: Access denied" -ForegroundColor Yellow
        return $false
    }
    elseif ($resultString -match "Computer") {
        Write-Host "  + NetSessionEnum: Found active sessions" -ForegroundColor Green
        return $true
    }
    
    Write-Host "  - NetSessionEnum: Not Available" -ForegroundColor Red
    return $false
}

function Test-RemoteRegistry {
    param ($target)
    Write-Host "  [*] Testing RemoteRegistry..." -ForegroundColor Gray
    $result = sc.exe \\$target query RemoteRegistry 2>&1
    $resultString = $result | Out-String
    
    if ($resultString -match "RUNNING") {
        Write-Host "  + RemoteRegistry: Service is running" -ForegroundColor Green
        return $true
    }
    elseif ($resultString -match "STOPPED") {
        Write-Host "  - RemoteRegistry: Service exists but stopped" -ForegroundColor Yellow
        return $false
    }
    elseif ($resultString -match "Access is denied") {
        Write-Host "  - RemoteRegistry: Access denied" -ForegroundColor Yellow
        return $false
    }
    else {
        Write-Host "  - RemoteRegistry: Not Available" -ForegroundColor Red
        return $false
    }
}

function Test-RegQuery {
    param ($target)
    Write-Host "  [*] Testing RegQuery (with ${RegQueryTimeout}s timeout)..." -ForegroundColor Gray
    
    $job = Start-Job -ScriptBlock {
        param($t)
        reg query "\\$t\HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" 2>&1
    } -ArgumentList $target

    if (Wait-Job $job -Timeout $RegQueryTimeout) {
        $result = Receive-Job $job
        Remove-Job $job -Force
        $resultString = $result | Out-String
        
        # Check for specific error conditions
        if ($resultString -match "network path was not found") {
            Write-Host "  - Registry Query: Network path not found" -ForegroundColor Red
            return $false
        }
        elseif ($resultString -match "Access is denied") {
            Write-Host "  - Registry Query: Access denied" -ForegroundColor Yellow
            return $false
        }
        elseif ($resultString -match "ERROR:") {
            Write-Host "  - Registry Query: Generic error occurred" -ForegroundColor Red
            return $false
        }
        
        # Only return true if we got actual registry data
        if ($resultString -match "HKEY_LOCAL_MACHINE") {
            Write-Host "  + Registry Query: Successfully accessed registry" -ForegroundColor Green
            return $true
        }
    } else {
        Write-Host "  - Registry Query: Timeout after ${RegQueryTimeout}s" -ForegroundColor Yellow
        Stop-Job $job
        Remove-Job $job -Force
        return $false
    }
    Write-Host "  - Registry Query: Not Available" -ForegroundColor Red
    return $false
}

function Test-PsLoggedOn {
    param ($target)
    Write-Host "  [*] Testing PsLoggedOn..." -ForegroundColor Gray
    $psLoggedOnPath = "C:\Tools\PSTools\PsLoggedon.exe"
    
    if (-not (Test-Path $psLoggedOnPath)) {
        Write-Host "  - PsLoggedOn: Tool not found at $psLoggedOnPath" -ForegroundColor Red
        return $false
    }
    
    $result = & $psLoggedOnPath \\$target 2>&1
    $resultString = $result | Out-String
    
    # Check for specific error conditions first
    if ($resultString -match "Access is denied") {
        Write-Host "  - PsLoggedOn: Access denied" -ForegroundColor Yellow
        return $false
    }
    
    # Consider it a success only if we find actual user data
    $hasLocalUsers = $resultString -match "Users logged on locally:"
    $hasResourceUsers = $resultString -match "Users logged on via resource shares:"
    
    # Check for the error but also verify if we got actual user data
    $hasRegistryError = $resultString -match "Error opening HKEY_USERS"
    
    if (($hasLocalUsers -or $hasResourceUsers) -and 
        ($resultString -match "CORP\\")) {
        Write-Host "  + PsLoggedOn: Found user sessions" -ForegroundColor Green
        return $true
    }
    
    Write-Host "  - PsLoggedOn: No valid sessions found" -ForegroundColor Red
    return $false
}

function Test-PowerView {
    param ($target)
    if (-not $powerViewLoaded) {
        Write-Host "  [-] PowerView not loaded - skipping test" -ForegroundColor Yellow
        return $false
    }
    
    Write-Host "  [*] Testing PowerView..." -ForegroundColor Gray
    try {
        if (-not (Get-Command Get-NetSession -ErrorAction SilentlyContinue)) {
            Write-Host "  [-] PowerView's Get-NetSession command not available" -ForegroundColor Red
            return $false
        }
        
        $result = Get-NetSession -ComputerName $target
        $resultString = $result | Out-String
        
        if ($resultString -and $resultString.Trim()) {
            Write-Host "  + PowerView: Found active sessions" -ForegroundColor Green
            return $true
        }
        elseif ($Error[0].ToString() -match "Access is denied") {
            Write-Host "  - PowerView: Access Denied" -ForegroundColor Yellow
            return $false
        }
        else {
            Write-Host "  - PowerView: No sessions found" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "  [-] PowerView session enumeration failed: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution loop
$successfulTargets = @()

foreach ($t in $targets) {
    Write-Host "`n[*] Testing Target: $t" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan

    # Test connectivity first
    if (Test-Connection -ComputerName $t -Count 1 -Quiet) {
        Write-Host "[+] Host is reachable" -ForegroundColor Green

        # Track successful methods
        $commandDetails = @{
            Target = $t
            Methods = @()
            Commands = @()
        }

        # Test each method and add command details if successful
        if (Test-NetSessionEnum $t) {
            Write-Host "  + NetSessionEnum: Working" -ForegroundColor Green
            $commandDetails.Methods += "NetSessionEnum"
            $commandDetails.Commands += [PSCustomObject]@{
                Method = "NetSessionEnum"
                Command = "net session \\$t"
                Description = "Lists active sessions using native net command"
            }
        }

        if (Test-RemoteRegistry $t) {
            Write-Host "  + RemoteRegistry: Working" -ForegroundColor Green
            $commandDetails.Methods += "RemoteRegistry"
            $commandDetails.Commands += [PSCustomObject]@{
                Method = "RemoteRegistry"
                Command = "sc.exe \\$t query RemoteRegistry"
                Description = "Checks Remote Registry service status"
            }
        }

        if (Test-PsLoggedOn -target $t -psLoggedOnPath $psLoggedOnPath) {
            Write-Host "  + PsLoggedOn: Working" -ForegroundColor Green
            $commandDetails.Methods += "PsLoggedOn"
            $commandDetails.Commands += [PSCustomObject]@{
                Method = "PsLoggedOn"
                Command = "$global:psLoggedOnPath \\$t"  # Set the full command
                Description = "Lists logged on users using Sysinternals PsLoggedOn"
            }
        }

        if (Test-PowerView $t) {
            Write-Host "  + PowerView: Working" -ForegroundColor Green
            $commandDetails.Methods += "PowerView"
            $commandDetails.Commands += [PSCustomObject]@{
                Method = "PowerView"
                Command = "Get-NetSession -ComputerName $t"
                Description = "Enumerates sessions using PowerView"
            }
        }

        if ($EnableRegQuery -and (Test-RegQuery $t)) {
            Write-Host "  + Registry Query: Working" -ForegroundColor Green
            $commandDetails.Methods += "RegQuery"
            $commandDetails.Commands += [PSCustomObject]@{
                Method = "RegQuery"
                Command = "reg query \\$t\HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion"
                Description = "Queries remote registry"
            }
        }

        # Add to successful targets if any methods worked
        if ($commandDetails.Methods.Count -gt 0) {
            $successfulTargets += [PSCustomObject]$commandDetails
        }

        # Summary for this target
        Write-Host "`nResults for $t" -ForegroundColor Cyan
        if ($commandDetails.Methods.Count -gt 0) {
            Write-Host "Working methods:" -ForegroundColor Green
            $commandDetails.Methods | ForEach-Object { Write-Host "  - $_" -ForegroundColor Green }
        }
        else {
            Write-Host "No working enumeration methods found" -ForegroundColor Red
        }
    }
    else {
        Write-Host "[-] Host is not reachable" -ForegroundColor Red
    }
}

# Final Summary and Command Execution
Write-Host "`n[*] Enumeration Complete" -ForegroundColor Cyan
if ($successfulTargets.Count -gt 0) {
    Write-Host "`n[+] Successful Enumeration Summary:" -ForegroundColor Green
    
    foreach ($target in $successfulTargets) {
        Write-Host "`nTarget: $($target.Target)" -ForegroundColor Cyan
        Write-Host "Working Methods and Available Commands:" -ForegroundColor Green
        
        foreach ($command in $target.Commands) {
            Write-Host "`n  Method: $($command.Method)" -ForegroundColor Yellow
            Write-Host "  Description: $($command.Description)" -ForegroundColor Gray
            Write-Host "  Command: $($command.Command)" -ForegroundColor Green
        }
    }
    
    # Prompt to run commands
    Write-Host "`n[?] Would you like to run the enumeration commands? (y/N): " -NoNewline -ForegroundColor Yellow
    $runCommands = Read-Host
    
    if ($runCommands -eq 'y') {
        foreach ($target in $successfulTargets) {
            Write-Host "`n[*] Running commands for $($target.Target):" -ForegroundColor Cyan
            
            foreach ($command in $target.Commands) {
                Write-Host "`n[>] Executing: $($command.Method)" -ForegroundColor Yellow
                Write-Host "[+] Command: $($command.Command)" -ForegroundColor Green
                Write-Host "----------------------------------------" -ForegroundColor Gray
                
                try {
                    switch ($command.Method) {
                        "PowerView" { 
                            Invoke-Expression $command.Command 
                        }
                        
                        "PsLoggedOn" { 
                            Write-Host "Running: $($global:psLoggedOnPath) \\$($target.Target)"
                            $result = & $global:psLoggedOnPath "\\$($target.Target)" 2>&1
                            if ($result) {
                                $result | ForEach-Object { Write-Host $_ }
                            }
                        }
                        
                        "RegQuery" { 
                            $job = Start-Job -ScriptBlock {
                                param($cmd)
                                cmd /c $cmd
                            } -ArgumentList $command.Command
                            
                            if (Wait-Job $job -Timeout $RegQueryTimeout) {
                                Receive-Job $job | ForEach-Object { Write-Host $_ }
                            } else {
                                Write-Host "Command timed out after $RegQueryTimeout seconds" -ForegroundColor Yellow
                                Stop-Job $job
                            }
                            Remove-Job $job -Force
                        }
                        
                        default { 
                            $result = cmd /c $command.Command 2>&1
                            if ($result) {
                                $result | ForEach-Object { Write-Host $_ }
                            }
                        }
                    }
                }
                catch {
                    Write-Host "[-] Error executing command: $_" -ForegroundColor Red
                    Write-Host $_.ScriptStackTrace -ForegroundColor Red
                }
                Write-Host "----------------------------------------" -ForegroundColor Gray
                
                # Add a small delay between commands
                Start-Sleep -Seconds 1
            }
        }
    }
} else {
    Write-Host "`n[-] No successful enumeration methods found on any target" -ForegroundColor Red
}

# Final cleanup
Write-Host "`n[*] Script execution completed" -ForegroundColor Cyan
if ($Error.Count -gt 0) {
    Write-Host "[!] Script completed with $($Error.Count) errors" -ForegroundColor Yellow
}