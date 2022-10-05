resource "kubernetes_namespace" "monitoring" {
  metadata {
    name        = "monitoring"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "monitoring" {
  name  = "monitoring"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  namespace = kubernetes_namespace.monitoring.metadata[0].name

  values = [<<EOF
alertmanager:
  ingress:
    enabled: true
    ingressClassName: "nginx"
    annotations:
      external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
      kubernetes.io/tls-acme: "true"
      cert-manager.io/cluster-issuer: ${kubectl_manifest.letsencrypt-prod.name}
    hosts:
      - alertmanager.${var.domain_name}

grafana:
  enabled: true
  namespaceOverride: ""

  adminPassword: ${random_password.bootstrap_password.result}

  ingress:
    enabled: true
    ingressClassName: "nginx"
    annotations:
      external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
      kubernetes.io/tls-acme: "true"
      cert-manager.io/cluster-issuer: ${kubectl_manifest.letsencrypt-prod.name}
    hosts:
      - grafana.${var.domain_name}

prometheus:
  enabled: true
  namespaceOverride: ""


  ingress:
    enabled: true
    ingressClassName: "nginx"
    annotations:
      external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
      kubernetes.io/tls-acme: "true"
      cert-manager.io/cluster-issuer: ${kubectl_manifest.letsencrypt-prod.name}
    hosts:
      - prometheus.${var.domain_name}

EOF
  ]
}


