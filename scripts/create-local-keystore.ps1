param(
    [string]$KeystorePath = ".local/tls/jetty-keystore.p12",
    [string]$StorePassword = "changeit",
    [string]$Alias = "uteshop-dev"
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$keystoreAbsolutePath = Join-Path $root $KeystorePath
$keystoreDir = Split-Path $keystoreAbsolutePath -Parent

if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null
}

if (Test-Path $keystoreAbsolutePath) {
    Write-Host "Keystore da ton tai: $keystoreAbsolutePath"
    exit 0
}

$keytool = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $keytool) {
    throw "Khong tim thay keytool. Hay cai JDK va dam bao keytool co trong PATH."
}

& $keytool.Source -genkeypair `
    -alias $Alias `
    -keyalg RSA `
    -keysize 2048 `
    -storetype PKCS12 `
    -keystore $keystoreAbsolutePath `
    -validity 3650 `
    -storepass $StorePassword `
    -keypass $StorePassword `
    -dname "CN=localhost, OU=Dev, O=UTESHOP, L=HCM, ST=HCM, C=VN" `
    -ext "SAN=dns:localhost,ip:127.0.0.1,ip:::1"

if ($LASTEXITCODE -ne 0) {
    throw "Tao keystore that bai."
}

Write-Host "Da tao keystore HTTPS: $keystoreAbsolutePath"
