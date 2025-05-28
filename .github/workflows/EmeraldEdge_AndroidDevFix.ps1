# Emerald Edge Android Dev Fix Script (v1.0) - May 2025

# Restart ADB
Write-Host "Restarting ADB..."
adb kill-server
adb start-server
adb devices

# System File Check
Write-Host "Running SFC..."
sfc /scannow

# DISM Check
Write-Host "Running DISM..."
DISM /Online /Cleanup-Image /RestoreHealth

# Set SDK Paths
$androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$platformTools = Join-Path $androidSdkPath "platform-tools"
if (Test-Path $androidSdkPath) {
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSdkPath, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidSdkPath, [EnvironmentVariableTarget]::Machine)
    $envPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if (-not ($envPath -like "*$platformTools*")) {
        [Environment]::SetEnvironmentVariable("Path", "$envPath;$platformTools", [EnvironmentVariableTarget]::Machine)
        Write-Host "SDK Path added to system PATH."
    }
}

# Emulator Restart
$avdManager = Join-Path $androidSdkPath "emulator\emulator.exe"
if (Test-Path $avdManager) {
    $avds = & $avdManager -list-avds
    foreach ($avd in $avds) {
        Start-Process $avdManager -ArgumentList "-avd $avd" -NoNewWindow
    }
} else {
    Write-Host "No emulator found."
}

# Flutter Doctor Check
Write-Host "Running Flutter Doctor..."
flutter doctor
