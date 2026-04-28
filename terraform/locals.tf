locals {
  common_tags = merge(var.tags, {
    component = "cyclecloud-deployment"
  })

  names = {
    private_dns_zone_kv = "privatelink.vaultcore.azure.net"
    private_dns_zone_blob = "privatelink.blob.core.windows.net"
    private_dns_zone_monitor = "privatelink.monitor.azure.com"
    private_dns_zone_oms = "privatelink.oms.opinsights.azure.com"
    private_dns_zone_ods = "privatelink.ods.opinsights.azure.com"
    private_dns_zone_agentsvc = "privatelink.agentsvc.azure-automation.net"
  }
}
