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

variable "enable_gitea" {
  type = string
}

# variable "s3_access_key" {
#   type      = string
#   sensitive = true
# }

# variable "s3_secret_key" {
#   type      = string
#   sensitive = true
# }

# variable "s3_bucket" {
#   type      = string
#   sensitive = true
# }

# variable "s3_host" {
#   type      = string
#   sensitive = true
# }