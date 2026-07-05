ui = true
disable_mlock = true

storage "file" {
  path = "C:/secure/uteshop/vault-data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

api_addr = "http://127.0.0.1:8200"
