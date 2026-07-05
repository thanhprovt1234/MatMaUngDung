ui = true

storage "file" {
  path = "C:/secure/uteshop/vault-data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

seal "gcpckms" {
  project    = "your-gcp-project-id"
  region     = "asia-southeast1"
  key_ring   = "uteshop-vault"
  crypto_key = "vault-auto-unseal"
}

api_addr = "http://127.0.0.1:8200"
