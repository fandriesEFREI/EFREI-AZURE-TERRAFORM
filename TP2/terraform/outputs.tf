output "ssh_connection" {
  description = "Affichage de l'IP publique et du nom DNS de  la VM"
  value       = "IP publique : ${azurerm_public_ip.main.ip_address} / Nom DNS : ${azurerm_public_ip.main.domain_name_label}"
}