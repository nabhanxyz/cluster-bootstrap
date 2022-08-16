
resource "kubernetes_namespace" "yopass" {
  metadata {
    name        = "yopass"
    annotations = {}
    labels      = {}
  }
}


resource "kubernetes_service" "yopass_memcached" {
  metadata {
    name      = "memcached"
    namespace = kubernetes_namespace.yopass.metadata[0].name

    labels = {
      "io.kompose.service" = "memcached"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -f docker-compose.yml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    port {
      name        = "11211"
      port        = 11211
      target_port = "11211"
    }

    selector = {
      "io.kompose.service" = "memcached"
    }
  }
}

resource "kubernetes_deployment" "yopass" {
  metadata {
    name      = "yopass"
    namespace = kubernetes_namespace.yopass.metadata[0].name

    labels = {
      "io.kompose.service" = "yopass"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -f docker-compose.yml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "io.kompose.service" = "yopass"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.service" = "yopass"
        }

        annotations = {
          "kompose.cmd" = "kompose convert -f docker-compose.yml"

          "kompose.version" = "1.26.1 (HEAD)"
        }
      }

      spec {
        container {
          name  = "yopass"
          image = "jhaals/yopass"
          args  = ["--memcached=memcached:11211", "--port", "80"]

          port {
            container_port = 80
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "yopass" {
  metadata {
    name      = "yopass"
    namespace = kubernetes_namespace.yopass.metadata[0].name

    labels = {
      "io.kompose.service" = "yopass"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -f docker-compose.yml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    port {
      name        = "80"
      port        = 80
      target_port = "80"
    }

    selector = {
      "io.kompose.service" = "yopass"
    }
  }
}

resource "kubernetes_deployment" "yopass_memcached" {
  metadata {
    name      = "memcached"
    namespace = kubernetes_namespace.yopass.metadata[0].name

    labels = {
      "io.kompose.service" = "memcached"
    }

    annotations = {
      "kompose.cmd" = "kompose convert -f docker-compose.yml"

      "kompose.version" = "1.26.1 (HEAD)"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "io.kompose.service" = "memcached"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.service" = "memcached"
        }

        annotations = {
          "kompose.cmd" = "kompose convert -f docker-compose.yml"

          "kompose.version" = "1.26.1 (HEAD)"
        }
      }

      spec {
        container {
          name  = "memcached"
          image = "memcached"

          port {
            container_port = 11211
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_ingress_v1" "yopass" {
  metadata {
    name      = kubernetes_namespace.yopass.metadata[0].name
    namespace = kubernetes_namespace.yopass.metadata[0].name
    annotations = {
      # "ingress.kubernetes.io/rewrite-target" = "/"
      # "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
      "external-dns.alpha.kubernetes.io/target"        = "tunnel-origin.${var.domain_name}"


    }
  }
  spec {
    default_backend {
      service {
        name = "default-http-backend"
        # name = "${kubernetes_namespace.yopass.metadata[0].name}.${kubernetes_namespace.yopass.metadata[0].name}.svc"
        port {
          number = 80
        }
      }
    }
    ingress_class_name = "nginx"

    rule {
      host = "secrets.${var.domain_name}"
      http {
        path {
          backend {
            service {
              name = kubernetes_namespace.yopass.metadata[0].name
              port {
                number = 80
              }
            }
          }

          path = "/"
        }
      }
    }
  }
}