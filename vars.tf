variable "cloudflare_zone_id" {
  type      = string
  sensitive = true
}

variable "cloudflare_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type      = string
  sensitive = true
}

variable "contact_email" {
  type      = string
  sensitive = true
}

variable "bootstrap_username" {
  type      = string
  sensitive = true
}

variable "bootstrap_password" {
  type      = string
  sensitive = true
}

variable "enable_gitea" {
  type      = string
}