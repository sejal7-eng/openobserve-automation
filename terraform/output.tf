output "namespace" {
  value = kubernetes_namespace.openobserve.metadata[0].name
}

output "release_name" {
  value = helm_release.openobserve.name
}
