data "cloudflare_zone" "zone_id" {
  name = var.domain_name
  account_id = var.cloudflare_account_id
}
