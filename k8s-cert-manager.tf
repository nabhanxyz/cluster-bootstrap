resource "kubernetes_namespace" "cert_manager" {
  metadata {
    annotations = {
      name = "cert-manager"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "cert-manager"
  }
}

resource "kubernetes_secret" "cf_token" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = kubernetes_namespace.cert_manager.metadata[0].annotations.name
  }

  data = {
    api-token = var.cloudflare_token
  }

  type = "Opaque"
  depends_on = [
    kubernetes_namespace.cert_manager,
  ]

}

resource "helm_release" "cert_manager" {

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.8.2"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].annotations.name

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "letsencrypt-staging" {
  depends_on = [
    helm_release.cert_manager,
  ]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${var.contact_email}
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-staging
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - dns01:
        cloudflare:
          email: ${var.contact_email}
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
YAML
}

resource "kubectl_manifest" "letsencrypt-prod" {
  depends_on = [
    helm_release.cert_manager,
  ]
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${var.contact_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-prod
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - dns01:
        cloudflare:
          email: ${var.contact_email}
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
YAML
}