resource "cloudflare_access_identity_provider" "authentik" {
  account_id = var.cloudflare_account_id
  name       = "Authentik"
  type       = "oidc"
  config {
    client_id     = random_password.authentik_cloudflare_client_id.result
    client_secret = random_password.authentik_cloudflare_client_secret.result
    issuer_url    = "https://auth.${var.domain_name}/application/o/cloudflare/"
    auth_url      = "https://auth.${var.domain_name}/application/o/authorize/"
    token_url     = "https://auth.${var.domain_name}/application/o/token/"
    certs_url     = "https://auth.${var.domain_name}/application/o/cloudflare/jwks/"
  }
}



resource "authentik_provider_oauth2" "cloudflare" {
  name          = "cloudflare"
  client_id     = random_password.authentik_cloudflare_client_id.result
  client_secret = random_password.authentik_cloudflare_client_secret.result
  #   client_type = "public"
  signing_key        = data.authentik_certificate_key_pair.generated.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  redirect_uris = [
    "https://${var.cloudflare_team_name}.cloudflareaccess.com/cdn-cgi/access/callback"

  ]
  property_mappings = data.authentik_scope_mapping.cloudflare.ids

}

resource "authentik_application" "cloudflare" {
  name              = "cloudflare"
  slug              = "cloudflare"
  protocol_provider = authentik_provider_oauth2.cloudflare.id
}


resource "random_password" "authentik_cloudflare_client_id" {
  length  = 40
  special = false
}

resource "random_password" "authentik_cloudflare_client_secret" {
  length  = 128
  special = false
}

data "authentik_scope_mapping" "cloudflare" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

##prometheus

resource "cloudflare_access_application" "prometheus" {
  zone_id                   = data.cloudflare_zone.zone_id.id
  name                      = "prometheus"
  domain                    = "prometheus.${var.domain_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

resource "cloudflare_access_policy" "prometheus" {
  application_id = cloudflare_access_application.prometheus.id
  zone_id        = cloudflare_access_application.prometheus.zone_id
  name           = "prometheus policy"
  precedence     = "1"
  decision       = "allow"

  include {
    email = ["${var.contact_email}"]
  }

  require {
    email = ["${var.contact_email}"]
  }
}

##alertmanager

resource "cloudflare_access_application" "alertmanager" {
  zone_id                   = data.cloudflare_zone.zone_id.id
  name                      = "alertmanager"
  domain                    = "alertmanager.${var.domain_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

resource "cloudflare_access_policy" "alertmanager" {
  application_id = cloudflare_access_application.alertmanager.id
  zone_id        = cloudflare_access_application.alertmanager.zone_id
  name           = "alertmanager policy"
  precedence     = "1"
  decision       = "allow"

  include {
    email = ["${var.contact_email}"]
  }

  require {
    email = ["${var.contact_email}"]
  }
}

##grafana

resource "cloudflare_access_application" "grafana" {
  zone_id                   = data.cloudflare_zone.zone_id.id
  name                      = "grafana"
  domain                    = "grafana.${var.domain_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

resource "cloudflare_access_policy" "grafana" {
  application_id = cloudflare_access_application.grafana.id
  zone_id        = cloudflare_access_application.grafana.zone_id
  name           = "grafana policy"
  precedence     = "1"
  decision       = "allow"

  include {
    email = ["${var.contact_email}"]
  }

  require {
    email = ["${var.contact_email}"]
  }
}

##longhorn

# resource "cloudflare_access_application" "longhorn" {
#   zone_id                   = data.cloudflare_zone.zone_id.id
#   name                      = "longhorn"
#   domain                    = "longhorn.${var.domain_name}"
#   type                      = "self_hosted"
#   session_duration          = "24h"
#   auto_redirect_to_identity = false
# }

# resource "cloudflare_access_policy" "longhorn" {
#   application_id = cloudflare_access_application.longhorn.id
#   zone_id        = cloudflare_access_application.longhorn.zone_id
#   name           = "longhorn policy"
#   precedence     = "1"
#   decision       = "allow"

#   include {
#     email = ["${var.contact_email}"]
#   }

#   require {
#     email = ["${var.contact_email}"]
#   }
# }