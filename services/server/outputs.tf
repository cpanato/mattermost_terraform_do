output "mattermost_server_ip" {
  value = "${digitalocean_droplet.mattermost_server.ipv4_address}"
}

output "mattermost_server_address_private" {
  value = "${digitalocean_droplet.mattermost_server.ipv4_address_private}"
}

output "mattermost_server_name" {
  value = "${digitalocean_droplet.mattermost_server.name}"
}

