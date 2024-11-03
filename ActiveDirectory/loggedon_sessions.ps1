function Get-PsLoggedOnPath {
    $defaultPaths = @{
        Path32 = "C:\Tools\PSTools\PsLoggedon.exe"
        Path64 = "C:\Tools\PSTools\PsLoggedon64.exe"
    }
    
    Write-Host "`n[*] Checking for PsLoggedOn executables..." -ForegroundColor Cyan
    
    $found32 = Test-Path $defaultPaths.Path32
    $found64 = Test-Path $defaultPaths.Path64
    
    if (-not ($found32 -or $found64)) {
        Write-Host "[!] PsLoggedOn executables not found in default path" -ForegroundColor Yellow
        Write-Host "[?] Enter path to PSTools folder (or press Enter to skip): " -NoNewline
        $customPath = Read-Host
        
        if ([string]::IsNullOrWhiteSpace($customPath)) {
            Write-Host "[-] PsLoggedOn functionality will be disabled" -ForegroundColor Red
            return $null
        }
        
        $defaultPaths.Path32 = Join-Path $customPath "PsLoggedon.exe"
        $defaultPaths.Path64 = Join-Path $customPath "PsLoggedon64.exe"
        $found32 = Test-Path $defaultPaths.Path32
        $found64 = Test-Path $defaultPaths.Path64
        
        if (-not ($found32 -or $found64)) {
            Write-Host "[-] No PsLoggedOn executables found in specified path" -ForegroundColor Red
            return $null
        }
    }
    
    if ($found64) { 
        Write-Host "[+] Using 64-bit version: $($defaultPaths.Path64)" -ForegroundColor Green
        return @{ Path = $defaultPaths.Path64 }
    }
    
    Write-Host "[+] Using 32-bit version: $($defaultPaths.Path32)" -ForegroundColor Green
    return @{ Path = $defaultPaths.Path32 }
}

function Test-PsLoggedOn {
    param (
        $target,
        $psLoggedOnPath
    )
    Write-Host "  [*] Testing PsLoggedOn..." -ForegroundColor Gray
    
    if (-not $psLoggedOnPath) {
        Write-Host "  - PsLoggedOn: Executable not found" -ForegroundColor Red
        return $false
    }
    
    try {
        $result = & $psLoggedOnPath.Path \\$target 2>&1
        $outputString = $result | Out-String
        
        if ($outputString -match "Access is denied") {
            Write-Host "  - PsLoggedOn: Access denied" -ForegroundColor Yellow
            return $false
        }
        
        $hasUsers = $outputString -match "Users logged on locally:|Users logged on via resource shares:"
        if ($hasUsers -and $outputString -match "CORP\\") {
            Write-Host "  + PsLoggedOn: Found user sessions" -ForegroundColor Green
            return $true
        }
        
        Write-Host "  - PsLoggedOn: No valid sessions found" -ForegroundColor Red
        return $false
    }
    catch {
        Write-Host "  - PsLoggedOn: Error executing command: $_" -ForegroundColor Red
        return $false
    }
}

function Execute-PsLoggedOn {
    param (
        $target,
        $psLoggedOnPath
    )
    try {
        $result = & $psLoggedOnPath.Path \\$target 2>&1
        if ($result) {
            $result | ForEach-Object { Write-Host $_ }
        }
    }
    catch {
        Write-Host "[-] Error executing PsLoggedOn: $_" -ForegroundColor Red
    }
}



# Session Enumeration Comprehensive Test Script v1.5
$ErrorActionPreference = 'SilentlyContinue'
Write-Host "[*] Session Enumeration Script Starting..." -ForegroundColor Cyan

# Get user preference for Registry enumeration
Write-Host "[?] Would you like to enable Registry enumeration? (slower) (y/N): " -NoNewline -ForegroundColor Yellow
$enableReg = Read-Host
$EnableRegQuery = $enableReg -eq 'y'
if ($EnableRegQuery) {
    Write-Host "[*] Registry enumeration enabled" -ForegroundColor Green
    Write-Host "[?] Enter Registry query timeout in seconds (default 5): " -NoNewline
    $timeout = Read-Host
    $RegQueryTimeout = if ($timeout -match '^\d+$') { [int]$timeout } else { 5 }
    Write-Host "[*] Registry timeout set to $RegQueryTimeout seconds" -ForegroundColor Green
} else {
    Write-Host "[*] Registry enumeration disabled" -ForegroundColor Yellow
}

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

        if (Test-PsLoggedOn $t) {
            Write-Host "  + PsLoggedOn: Working" -ForegroundColor Green
            $commandDetails.Methods += "PsLoggedOn"
            $commandDetails.Commands += [PSCustomObject]@{
                Method = "PsLoggedOn"
                Command = "C:\Tools\PSTools\PsLoggedon.exe \\$t"
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
                            # Execute PowerView command directly through PowerShell
                            Invoke-Expression $command.Command
                        }
                        "PsLoggedOn" {
                            # Execute PsLoggedOn as an external process
                            try {
                                $result = & $command.Command $command.Arguments 2>&1
                                if ($result) {
                                    $result | ForEach-Object { Write-Host $_ }
                                }
                            }
                            catch {
                                Write-Host "[-] Error executing PsLoggedOn: $_" -ForegroundColor Red
                            }
                        }
                        }
                        "RegQuery" {
                            # Execute reg query with timeout protection
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
                            # Execute other commands through cmd.exe
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