resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name        = "longhorn-system"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  namespace  = kubernetes_namespace.longhorn_system.metadata[0].name
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"

  set {
    name  = "defaultSettings.backupTarget"
    value = "s3://${var.s3_bucket}@fakeregion/longhorn"
  }
  set {
    name  = "defaultSettings.backupTargetCredentialSecret"
    value = kubernetes_secret.longhorn_backup_target_secret.metadata[0].name
  }
}

resource "cloudflare_record" "longhorn" {
  zone_id = data.cloudflare_zone.zone_id.id
  name    = "longhorn.${var.domain_name}"
  value   = "tunnel-origin.${var.domain_name}"
  type    = "CNAME"
  proxied = true
}

resource "kubernetes_ingress_v1" "longhorn_ingress" {
  metadata {
    name      = "longhorn-ingress"
    namespace = kubernetes_namespace.longhorn_system.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/auth-realm" = "Authentication Required "
      "nginx.ingress.kubernetes.io/auth-secret" = "basic-auth"
      "nginx.ingress.kubernetes.io/auth-type" = "basic"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10000m"
    #   "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    #   "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
    host = "longhorn.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "longhorn-frontend"

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "longhorn_basic_auth" {
  metadata {
    name      = "basic-auth"
    namespace = kubernetes_namespace.longhorn_system.metadata[0].name
  }

  data = {
    auth      = <<EOF
${var.bootstrap_username}:${bcrypt(random_password.bootstrap_password.result)}
EOF
  }

  type = "Opaque"
}

resource "kubernetes_secret" "longhorn_backup_target_secret" {
  metadata {
    name      = "backup"
    namespace = kubernetes_namespace.longhorn_system.metadata[0].name
  }

  data = {
    AWS_ACCESS_KEY_ID = var.s3_access_key
    AWS_SECRET_ACCESS_KEY = var.s3_secret_key
    AWS_ENDPOINTS = "https://${var.s3_host}"   
  }

  type = "Opaque"
}