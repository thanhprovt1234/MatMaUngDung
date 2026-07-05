# UTEShop Secrets Management With Vault

## Runtime Flow

```text
GCP Cloud KMS
        |
        | auto-unseal Vault
        v
Vault KV secret/uteshop/prod
        |
        | AppRole policy: read only this path
        v
Vault Agent
        |
        | renders C:\secure\uteshop\secrets.properties
        v
Jetty / Java Web App
        |
        | SecretsConfig reads secrets at startup
        v
MySQL, Google OIDC, AES-GCM, JWT, SMTP
```

The Java app never stores a Vault root token and does not commit real secrets to Git. In production, `C:\secure\uteshop\secrets.properties` should be created by Vault Agent and protected by OS file permissions.

GCP Cloud KMS is used at the Vault infrastructure layer, not directly by the Java app. Vault uses the GCP KMS key to auto-unseal itself after restart.

## Secret Path

Use a KV v2 secret path:

```text
secret/uteshop/prod
```

Recommended keys:

```text
DB_URL
DB_USER
DB_PASSWORD
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
GOOGLE_REDIRECT_URI
FIELD_ENCRYPTION_KEY
JWT_SECRET
SMTP_HOST
SMTP_PORT
SMTP_USERNAME
SMTP_PASSWORD
SMTP_FROM
SMTP_FROM_NAME
SMTP_STARTTLS
FORCE_SECURE_COOKIE
```

## Vault Policy

```hcl
path "secret/data/uteshop/prod" {
  capabilities = ["read"]
}

path "transit/encrypt/uteshop-field-encryption" {
  capabilities = ["update"]
}

path "transit/decrypt/uteshop-field-encryption" {
  capabilities = ["update"]
}
```

## AppRole

```powershell
vault auth enable approle
vault policy write uteshop-app vault/uteshop-policy.hcl
vault write auth/approle/role/uteshop-app `
  token_policies="uteshop-app" `
  token_ttl="1h" `
  token_max_ttl="4h" `
  secret_id_ttl="24h" `
  secret_id_num_uses="1"
```

Then fetch:

```powershell
vault read auth/approle/role/uteshop-app/role-id
vault write -f auth/approle/role/uteshop-app/secret-id
```

Store the generated `role_id` and `secret_id` outside Git, for example in protected files used by Vault Agent.

## Vault Agent Template

Vault Agent should render:

```text
C:\secure\uteshop\secrets.properties
```

Then start Jetty normally. The app reads the rendered file first, then falls back to environment variables if the file is not present.

Optional override:

```powershell
$env:UTESHOP_SECRETS_FILE = "C:\secure\uteshop\secrets.properties"
```

or:

```powershell
mvn jetty:run -Duteshop.secrets.file=C:\secure\uteshop\secrets.properties
```

## Add GCP Cloud KMS For Vault Auto-Unseal

Use this when moving from local/manual Vault to a more production-like setup.

### 1. Choose IDs

```powershell
$env:GCP_PROJECT_ID = "your-gcp-project-id"
$env:GCP_LOCATION = "asia-southeast1"
$env:GCP_KEY_RING = "uteshop-vault"
$env:GCP_KEY = "vault-auto-unseal"
$env:GCP_SERVICE_ACCOUNT = "uteshop-vault-kms"
```

### 2. Enable Cloud KMS API

```powershell
gcloud config set project $env:GCP_PROJECT_ID
gcloud services enable cloudkms.googleapis.com
```

### 3. Create KMS Key Ring And Key

```powershell
gcloud kms keyrings create $env:GCP_KEY_RING `
  --location $env:GCP_LOCATION

gcloud kms keys create $env:GCP_KEY `
  --location $env:GCP_LOCATION `
  --keyring $env:GCP_KEY_RING `
  --purpose encryption
```

### 4. Create Service Account For Vault

```powershell
gcloud iam service-accounts create $env:GCP_SERVICE_ACCOUNT `
  --display-name "UTESHOP Vault KMS"

$env:GCP_SA_EMAIL = "$env:GCP_SERVICE_ACCOUNT@$env:GCP_PROJECT_ID.iam.gserviceaccount.com"
```

### 5. Grant Least-Privilege KMS Permission

Vault needs encrypt/decrypt permission on the KMS key used for auto-unseal.

```powershell
gcloud kms keys add-iam-policy-binding $env:GCP_KEY `
  --location $env:GCP_LOCATION `
  --keyring $env:GCP_KEY_RING `
  --member "serviceAccount:$env:GCP_SA_EMAIL" `
  --role "roles/cloudkms.cryptoKeyEncrypterDecrypter"
```

### 6. Create A Service Account Key For Local/VM Testing

```powershell
New-Item -ItemType Directory -Force C:\secure\uteshop | Out-Null

gcloud iam service-accounts keys create C:\secure\uteshop\gcp-vault-kms.json `
  --iam-account $env:GCP_SA_EMAIL
```

Do not commit this JSON file.

### 7. Configure Vault Server

Use [vault-server-gcpkms.example.hcl](../vault/vault-server-gcpkms.example.hcl) as the starting point and replace:

```hcl
seal "gcpckms" {
  project    = "your-gcp-project-id"
  region     = "asia-southeast1"
  key_ring   = "uteshop-vault"
  crypto_key = "vault-auto-unseal"
}
```

Before starting Vault locally:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\secure\uteshop\gcp-vault-kms.json"
vault server -config=vault/vault-server-gcpkms.example.hcl
```

### 8. Expected Result

After Vault is initialized once, future Vault restarts should no longer require manual `vault operator unseal`. Vault asks GCP Cloud KMS to decrypt the seal material during startup.

The Java web app does not change for this step. It still reads secrets through `SecretsConfig`, preferably from the file rendered by Vault Agent.

## Add Vault Transit As Application KMS

Vault KV stores secrets. Vault Transit works as an application-level KMS: encryption keys stay inside Vault, and the Java app only sends plaintext/ciphertext to Vault.

### 1. Enable Transit And Create The Key

```powershell
$env:VAULT_ADDR="http://127.0.0.1:8200"
vault secrets enable transit
vault write -f transit/keys/uteshop-field-encryption `
  type=aes256-gcm96 `
  exportable=false `
  allow_plaintext_backup=false
```

### 2. Update App Policy

```powershell
vault policy write uteshop-app vault/uteshop-policy.hcl
```

The app policy allows:

```text
transit/encrypt/uteshop-field-encryption
transit/decrypt/uteshop-field-encryption
```

### 3. Render Transit Runtime Settings

Vault Agent renders these non-secret runtime settings:

```properties
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN_FILE=C:/secure/uteshop/vault-agent-token
VAULT_TRANSIT_ENABLED=true
VAULT_TRANSIT_KEY=uteshop-field-encryption
```

Restart Vault Agent after changing the template:

```powershell
vault agent -config="vault/vault-agent.example.hcl"
```

### 4. Java Runtime Behavior

`FieldEncryptionUtils` now supports two formats:

```text
ENC:v1:...      legacy AES-GCM using FIELD_ENCRYPTION_KEY
vault:v1:...    Vault Transit ciphertext
```

New encrypted values use Vault Transit when `VAULT_TRANSIT_ENABLED=true`. Existing database values encrypted with `ENC:v1` can still be decrypted using the legacy `FIELD_ENCRYPTION_KEY`, so the database does not need an immediate migration.
