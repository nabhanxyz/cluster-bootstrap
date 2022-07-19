# Kubernetes DevOPS Bootstrap Cluster

This is a project to set up a cluster with *everything* you need to get up and running to ops your dev.  It handles provisioning open-source and free software to enable you to develop, build, test, deliver, and monitor your software.  This cluster is meant to act as a "shared-services" style cluster, meaning that it provides core components necessary to wherever your software is actually running, such as version control (git), ci (argo-workflows), cd (argocd), SSO authentication (authentik), secrets management (HashiCorp vault), all of which is managed securely in an automated fashion with external-dns, cert-manager, and allows avoiding public endpoints like LoadBalancers or Public IPs or port forwards by leveraging cloudflare tunnels.

# Overview

## Assumptions/Dependencies

### Cloudflare

This project heavily leverages cloudflare for several functions:

 - Tunneling into the cluster
 - DNS APIs for bootstrapping and external-dns

## Roadmap/To-DO

 - Implement RBAC
 - Add flag for cloudflare
 - Declaratively Setup Argo Workflows Authentication with Authentik
 - Declaratively Setup ArgoCD Authentication with Authentik
 - Setup ArgoCD Default Repository
 - Setup Argo Workflows to be deployed with ArgoCD
 - Implement Vault Sensibly
 - Implement Observability Stack with Metrics and Log Shipping
 - Implement Pull Style Monitoring with API Driven Provider

 # Installation and Use
 
  Right now, all you need to do is provide a kubeconfig called `./bootstrap.kubeconfig` and copy the terraform.tfvars.example into the root directory and populate with the appropriate values.