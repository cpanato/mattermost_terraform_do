output "mattermost_db" {
  value = "${digitalocean_droplet.mattermost_db.ipv4_address}"
}

output "mattermost_server" {
  value = "${digitalocean_droplet.mattermost_server.ipv4_address}"
}