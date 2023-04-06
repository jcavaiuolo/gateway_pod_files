# Configure the Linode Provider
terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      # version = "..."
    }
  }
}

provider "linode" {
  token = var.token
}

# Linode Instances
resource "linode_instance" "srv1_example_instance" {
  label          = "srv1_example_instance"
  tags           = ["demoLinode"]
  image          = "linode/ubuntu18.04"
  region         = "us-central"
  type           = "g6-nanode-1"
  root_pass      = var.root_pass
  private_ip     = true
  stackscript_id = var.stackscript_id

  stackscript_data = {
    "instance_label" = "srv1_example_instance"
  }
}

resource "linode_instance" "srv2_example_instance" {
  label          = "srv2_example_instance"
  tags           = ["demoLinode"]
  image          = "linode/ubuntu18.04"
  region         = "us-central"
  type           = "g6-nanode-1"
  root_pass      = var.root_pass
  private_ip     = true
  stackscript_id = var.stackscript_id

  stackscript_data = {
    "instance_label" = "srv2_example_instance"
  }
}

resource "linode_instance" "srv3_example_instance" {
  label          = "srv3_example_instance"
  tags           = ["demoLinode"]
  image          = "linode/ubuntu18.04"
  region         = "us-central"
  type           = "g6-nanode-1"
  root_pass      = var.root_pass
  private_ip     = true
  stackscript_id = var.stackscript_id

  stackscript_data = {
    "instance_label" = "srv3_example_instance"
  }
}

# Linode NodeBalancer
resource "linode_nodebalancer" "demoLinode_LoadBalancer" {
  label  = "demoLinode_LoadBalancer"
  region = "us-central"
  tags   = ["demoLinode"]
}

resource "linode_nodebalancer_config" "demoLinode_LoadBalancer-config" {
  nodebalancer_id = linode_nodebalancer.demoLinode_LoadBalancer.id
  port            = 80
  protocol        = "http"
  stickiness      = "none"
  algorithm       = "roundrobin"
}

resource "linode_nodebalancer_node" "demoLinode_LoadBalancer-node1" {
  label           = "srv1_example_instance"
  nodebalancer_id = linode_nodebalancer.demoLinode_LoadBalancer.id
  config_id       = linode_nodebalancer_config.demoLinode_LoadBalancer-config.id
  address         = "${linode_instance.srv1_example_instance.private_ip_address}:80"
  mode            = "accept"
  weight          = 100
}

resource "linode_nodebalancer_node" "demoLinode_LoadBalancer-node2" {
  label           = "srv2_example_instance"
  nodebalancer_id = linode_nodebalancer.demoLinode_LoadBalancer.id
  config_id       = linode_nodebalancer_config.demoLinode_LoadBalancer-config.id
  address         = "${linode_instance.srv2_example_instance.private_ip_address}:80"
  mode            = "accept"
  weight          = 100
}

resource "linode_nodebalancer_node" "demoLinode_LoadBalancer-node3" {
  label           = "srv3_example_instance"
  nodebalancer_id = linode_nodebalancer.demoLinode_LoadBalancer.id
  config_id       = linode_nodebalancer_config.demoLinode_LoadBalancer-config.id
  address         = "${linode_instance.srv3_example_instance.private_ip_address}:80"
  mode            = "accept"
  weight          = 100
}

# Domain
resource "linode_domain" "demolinode_net_domain" {
  domain    = "demolinode.net"
  soa_email = "demo@linode.net"
  type      = "master"
}

# Domain record
resource "linode_domain_record" "demolinode_net_domain_record" {
  domain_id   = linode_domain.demolinode_net_domain.id
  name        = "www"
  record_type = "A"
  target      = linode_nodebalancer.demoLinode_LoadBalancer.ipv4
  ttl_sec     = 30
}

# Firewall
resource "linode_firewall" "demoLinodeFirewall" {
  label = "demoLinodeFirewall_label"
  inbound {
    label    = "allow_http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["ff00::/8"]
  }
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"
  linodes         = [linode_instance.srv1_example_instance.id]

}


# variables
variable "token" {}
variable "root_pass" {}
variable "stackscript_id" {}
