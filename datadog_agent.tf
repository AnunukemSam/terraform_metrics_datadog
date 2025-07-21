resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  version    = "3.63.0"
  namespace  = "datadog"
  create_namespace = true

  values = [
    templatefile("${path.module}/datadog-values.yaml.tpl", {
      datadog_api_key = var.datadog_api_key
    })
  ]

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}