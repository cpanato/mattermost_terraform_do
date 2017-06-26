output "mattermost_db" {
  value = "${module.db.mattermost_db_ip}"
}

output "mattermost_server" {
  value = "${module.server.mattermost_server_ip}"
}

output "DNS" {
  value = "${module.dns.domains}"
}
