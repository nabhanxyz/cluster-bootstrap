resource "authentik_provider_oauth2" "argocd" {
  name      = "argocd"
  client_id = random_password.authentik_argocd_client_id.result
  client_secret = random_password.authentik_argocd_client_secret.result
#   client_type = "public"
  signing_key = data.authentik_certificate_key_pair.generated.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  redirect_uris = [
    "https://argocd.${var.domain_name}/api/dex/callback",
    "https://argo-wf.${var.domain_name}/oauth2/callback"

  ]
  property_mappings = data.authentik_scope_mapping.argocd.ids

}

resource "authentik_application" "argocd" {
  name              = "argocd"
  slug              = "argocd"
  protocol_provider = authentik_provider_oauth2.argocd.id
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

data "authentik_scope_mapping" "argocd" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}


resource "random_password" "authentik_argocd_client_id" {
  length           = 40
  special          = false
}

resource "random_password" "authentik_argocd_client_secret" {
  length           = 128
  special          = false
}