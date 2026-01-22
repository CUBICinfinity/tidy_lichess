param(
    [string]$ImageTag = "tidy_lichess",
    [string]$ContainerName = "",
    [switch]$Detach,
    [switch]$Keep
)

if (-not $ContainerName) {
    $ContainerName = $ImageTag
}

# Mount current directory to /app in container
$mountPath = (Get-Location).Path

# Build the command
$cmd = "docker run -it"

if ($Detach) {
    $cmd += " -d"
}

if (-not $Keep) {
    $cmd += " --rm"
}

$cmd += " -v `"${mountPath}:/app`""
$cmd += " --name $ContainerName"
$cmd += " $ImageTag"

Write-Host "Running: $cmd"
Invoke-Expression $cmd
