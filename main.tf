# Create Mattermost DB instance
module "db" {
  source = "./services/db"

  token             = "${var.token}"
  ssh_keys          = "${var.digitalocean_ssh_keys}"
  db_root_password  = "root"
  hostname_format   = "${var.hostname_format}"
  hostname_database = "${var.hostname_database}"
  db_region         = "FRA1"
  db_image          = "ubuntu-16-04-x64"
  db_size           = "1gb"
}

# Create Mattermost Server instance
module "server" {
  source = "./services/server"

  token           = "${var.token}"
  ssh_keys        = "${var.digitalocean_ssh_keys}"
  hostname_format = "${var.hostname_format}"
  hostname_server = "${var.hostname_server}"
  server_region   = "FRA1"
  server_image    = "ubuntu-16-04-x64"
  server_size     = "1gb"

  mattermost_admin_email              = "${var.mattermost_admin_email}"
  mattermost_admin_username           = "${var.mattermost_admin_username}"
  mattermost_admin_password           = "${var.mattermost_admin_password}"
  mattermost_initial_teamname         = "${var.mattermost_initial_teamname}"
  mattermost_initial_display_teamname = "${var.mattermost_initial_display_teamname}"
  mattermost_db_ip                    = "${module.db.mattermost_db_ip}"
}

# Create DNS
module "dns" {
  source = "./dns/cloudflare"

  count      = "1"
  email      = "${var.cloudflare_email}"
  token      = "${var.cloudflare_token}"
  domain     = "${var.domain}"
  public_ip  = "${module.server.mattermost_server_ip}"
  hostname   = "${module.server.mattermost_server_name}"
}

# Setup Firewall
module "firewall" {
  source = "./security/ufw"

  connection_db            = "${module.db.mattermost_db_ip}"
  connection_server        = "${module.server.mattermost_server_ip}"
  private_interface_db     = "${module.db.mattermost_db_address_private}"
  private_interface_server = "${module.server.mattermost_server_address_private}"

}

# Configure https
# resource "null_resource" "configure_https" {
#   connection {
#     user  = "root"
#     agent = true
#     host  = "${module.server.mattermost_server_ip}"
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "git clone https://github.com/letsencrypt/letsencrypt",
#       "cd letsencrypt",
#       "service nginx stop",
#       "systemctl stop nginx",
#       "./letsencrypt-auto certonly -n --standalone -m ctadeu@gmail.com --agree-tos -d mattermost.undergroundtest.tech",
#       "service nginx start",
#       "systemctl start nginx"
#     ]
#   }
# }