vault {
  address = "http://127.0.0.1:8200"
}

auto_auth {
  method "approle" {
    mount_path = "auth/approle"

    config = {
      role_id_file_path   = "C:/secure/uteshop/role_id"
      secret_id_file_path = "C:/secure/uteshop/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "C:/secure/uteshop/vault-agent-token"
    }
  }
}

template {
  source      = "vault/uteshop-secrets.properties.ctmpl"
  destination = "C:/secure/uteshop/secrets.properties"
  perms       = "0600"
}
