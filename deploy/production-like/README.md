# UTESHOP production-like Docker stack

This stack is the first step before splitting the monolith into real microservices.

It runs:

- `envoy`: public API gateway on `http://localhost:8088`
- `uteshop-web`: current Java/JSP app on the private Docker network
- `postgres`: app database on host port `5432`
- `vault`: local dev Vault on host port `8200`
- `vault-bootstrap`: creates the Transit key used by field encryption
- `keycloak`: IdP sandbox on `http://localhost:8080`

The Vault container uses dev mode for local integration testing only. Do not use this Vault mode in production.

## 1. Prepare env file

```powershell
Copy-Item .\deploy\production-like\.env.example .\deploy\production-like\.env
notepad .\deploy\production-like\.env
```

Replace at least:

- `POSTGRES_PASSWORD`
- `FIELD_ENCRYPTION_KEY`
- `JWT_SECRET`
- `SMTP_*` if you want OTP email to work
- `STRIPE_*` if you want checkout to work

Generate a base64 AES key for `FIELD_ENCRYPTION_KEY`:

```powershell
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

## 2. Start platform

```powershell
docker compose --env-file .\deploy\production-like\.env -f .\deploy\production-like\docker-compose.yml up --build
```

Open:

```text
http://localhost:8088/uteshop/home
```

Keycloak:

```text
http://localhost:8080
username: value of KEYCLOAK_ADMIN_USERNAME
password: value of KEYCLOAK_ADMIN_PASSWORD
realm: uteshop
client: uteshop-web
lab user: lab-user / ChangeMe123!
```

## 3. Test gateway path

```powershell
curl.exe -I http://localhost:8088/uteshop/home --max-time 20
curl.exe http://localhost:9901/server_info --max-time 10
```

## 4. Stop platform

```powershell
docker compose --env-file .\deploy\production-like\.env -f .\deploy\production-like\docker-compose.yml down
```

To reset the MySQL volume:

```powershell
docker compose --env-file .\deploy\production-like\.env -f .\deploy\production-like\docker-compose.yml down -v
```

## Next step

After this stack runs, add Keycloak OIDC login in the Java app. After that, split the monolith by moving payment first:

```text
Envoy /api/payments/* -> payment-service
Envoy /uteshop/*      -> uteshop-web
```
