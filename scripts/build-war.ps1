$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $root

try {
    & mvn clean package
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed."
    }

    Write-Host "Build thanh cong: target/uteshop.war" -ForegroundColor Green
}
finally {
    Pop-Location
}
