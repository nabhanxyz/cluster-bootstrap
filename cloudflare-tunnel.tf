resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_argo_tunnel" "bootstrap" {
  account_id = var.cloudflare_account_id
  name       = var.domain_name
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_record" "tunnel" {
  zone_id = var.cloudflare_zone_id
  name    = "tunnel-origin.${var.domain_name}"
  value   = "${cloudflare_argo_tunnel.bootstrap.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = false
}