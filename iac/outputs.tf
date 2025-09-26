output "vm_db_private_ip" {
  value       = module.compute.vm_db_private_ip
  description = "IP privada de la VM de base de datos"
}

output "vm_bkp_public_ip" {
  value       = module.compute.vm_bkp_public_ip
  description = "IP pública de la VM de backup (jump server)"
}

output "aks_kubeconfig" {
  value       = module.aks.kube_config
  description = "Kubeconfig del clúster AKS"
  sensitive   = true
}

output "ssh_public_key" {
  value       = var.ssh_public_key
  description = "Clave pública usada para acceder a las VMs"
  sensitive   = false
}

