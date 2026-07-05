param(
    [string]$SecretKey = $env:STRIPE_SECRET_KEY,
    [int]$Amount = 1999,
    [string]$Currency = $env:STRIPE_CURRENCY,
    [string]$PaymentMethod = "pm_card_visa",
    [string]$EvidenceOut = "target/stripe-api-smoke-test.json"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SecretKey)) {
    throw "Set STRIPE_SECRET_KEY to a real Stripe test secret key."
}
if ([string]::IsNullOrWhiteSpace($Currency)) {
    $Currency = "usd"
}

$headers = @{
    Authorization = "Bearer $SecretKey"
}

$body = @{
    amount = $Amount
    currency = $Currency.ToLowerInvariant()
    payment_method = $PaymentMethod
    confirm = "true"
    "metadata[source]" = "uteshop-smoke-test"
    "metadata[pan_retained]" = "false"
    "metadata[cvv_retained]" = "false"
}

$response = Invoke-RestMethod `
    -Method Post `
    -Uri "https://api.stripe.com/v1/payment_intents" `
    -Headers $headers `
    -ContentType "application/x-www-form-urlencoded" `
    -Body $body

$evidence = [ordered]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    gateway = "Stripe"
    apiEndpoint = "https://api.stripe.com/v1/payment_intents"
    paymentIntentId = $response.id
    amount = $response.amount
    currency = $response.currency
    status = $response.status
    paymentMethod = $PaymentMethod
    panRetainedByApp = $false
    cvvRetainedByApp = $false
}

$outDir = Split-Path -Parent $EvidenceOut
if ($outDir) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
$evidence | ConvertTo-Json -Depth 10 | Set-Content -Path $EvidenceOut -Encoding UTF8
Write-Host "Stripe API smoke test evidence written to $EvidenceOut"
