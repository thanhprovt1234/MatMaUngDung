path "secret/data/uteshop/prod" {
  capabilities = ["read"]
}

path "transit/encrypt/uteshop-field-encryption" {
  capabilities = ["update"]
}

path "transit/decrypt/uteshop-field-encryption" {
  capabilities = ["update"]
}
