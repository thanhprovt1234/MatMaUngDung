# Apache TLS setup notes

Use these samples when you want to configure Apache like Week07 Task 5.

There are two possible modes:

1. `uteshop-java-reverse-proxy.conf`
   - Keep the original Java/JSP project.
   - Run Jetty locally on `http://127.0.0.1:8081`.
   - Apache terminates TLS on port `443` and proxies to Jetty.

2. `uteshop-php-vhost.conf`
   - Serve the PHP/MySQL InfinityFree-compatible version directly from Apache.
   - Requires PHP installed and configured with Apache.

Your current Apache cert in `C:\Apache24\conf\ssl` is issued for:

```text
nxt04.kesug.com
```

For the new domain, request a new ZeroSSL certificate for:

```text
uteshop.kesug.com
```

The browser will only trust the connection when the URL hostname matches the certificate SAN/CN.

## Required Apache modules

In `C:\Apache24\conf\httpd.conf`, enable:

```apache
LoadModule ssl_module modules/mod_ssl.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
LoadModule headers_module modules/mod_headers.so
LoadModule rewrite_module modules/mod_rewrite.so
```

For Java reverse proxy mode, also enable:

```apache
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
```

Make sure this include is enabled:

```apache
Include conf/extra/httpd-ssl.conf
```

You may also include a custom vhost file:

```apache
Include conf/extra/uteshop-java-reverse-proxy.conf
```

or:

```apache
Include conf/extra/uteshop-php-vhost.conf
```

## Local DNS

For local testing on your machine, add to `C:\Windows\System32\drivers\etc\hosts`:

```text
127.0.0.1 uteshop.kesug.com
```

For public hosting, the DNS `A` record must point to the public IP of the server running Apache.

## Test

```powershell
C:\Apache24\bin\httpd.exe -t
C:\Apache24\bin\httpd.exe -k restart
openssl s_client -connect uteshop.kesug.com:443 -servername uteshop.kesug.com -showcerts
```
