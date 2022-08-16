resource "random_password" "bootstrap_password" {
  length  = 18
  special = true
}

data "cloudflare_zone" "zone_id" {
  name       = var.domain_name
  account_id = var.cloudflare_account_id
}
