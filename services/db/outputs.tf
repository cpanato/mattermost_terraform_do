output "mattermost_db_ip" {
  value = "${digitalocean_droplet.mattermost_db.ipv4_address}"
}

output "mattermost_db_address_private" {
  value = "${digitalocean_droplet.mattermost_db.ipv4_address_private}"
}
