# Tell terraform to use the provider and select a version.
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}
variable "hcloud_token" {
  sensitive = true
}
provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_firewall" "ssh_firewall" {
  name = "SSH to reverse proxy"
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

}

resource "hcloud_primary_ip" "ReverseProxyIpv4_1" {
  name          = "ReverseProxyIpv4_1"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
}

resource "hcloud_server" "MainAndReverseProxy" {
  name        = "MainAndReverseProxy"
  image       = "ubuntu-24.04"
  server_type = "cx22"
  location    = "fsn1"
  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.ReverseProxyIpv4_1.id
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.network.id
  }
  depends_on = [
    hcloud_network_subnet.network-subnet, hcloud_primary_ip.ReverseProxyIpv4_1
  ]
  user_data    = file("cloudinit/reverse_proxy.yml")
  firewall_ids = [hcloud_firewall.ssh_firewall.id]
}

resource "hcloud_server" "Slave" {
  name        = "Slave"
  image       = "ubuntu-24.04"
  server_type = "cx22"
  location    = "fsn1"
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }
  network {
    network_id = hcloud_network.network.id
  }
  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
  user_data = file("cloudinit/slave.yml")
}
