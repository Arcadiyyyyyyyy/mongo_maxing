output "instance_ids" {
  description = "IDs of Slave instances"
  value       = hcloud_server.Slave.*.id
}
output "network_id" {
  value = hcloud_network.network.id
}
output "ssh_key" {
  value = hcloud_ssh_key.ssh_access_key.public_key
}
