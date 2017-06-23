provider "digitalocean" {
  token = "${var.token}"
}

resource "digitalocean_droplet" "mattermost_db" {
  name               = "${format(var.hostname_format, var.hostname_database)}"
  region             = "${var.region}"
  image              = "${var.image}"
  size               = "${var.size}"
  backups            = false
  private_networking = true
  ssh_keys           = "${var.digitalocean_ssh_keys}"

  count = 1

  provisioner "remote-exec" {
    inline = [
      "until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",
      "apt-get update",
      "echo \"Europe/Berlin\" > /etc/timezone",
      "echo \"mysql-server mysql-server/root_password password ${var.db_root_password}\" | debconf-set-selections",
      "echo \"mysql-server mysql-server/root_password_again password ${var.db_root_password}\" | debconf-set-selections",
      "apt-get install -y mysql-server aptitude"
    ]
  }

  provisioner "remote-exec" {
    script = "scripts/mysql_secure_installation.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mysql -u root -p${var.db_root_password} -e \"create user 'mmuser'@'%' identified by 'mostest';\"",
      "mysql -u root -p${var.db_root_password} -e \"create user 'mmuser'@'${digitalocean_droplet.mattermost_db.ipv4_address}' identified by 'mostest';\"",
      "mysql -u root -p${var.db_root_password} -e \"create database mattermost;\"",
      "mysql -u root -p${var.db_root_password} -e \"grant all privileges on mattermost.* to 'mmuser'@'%';\"",
    ]
  }
}

data "template_file" "mattermost_mysql_cf" {
  template = "${file("templates/my.cnf.tpl")}"

  vars {
    mattermost_db     = "${digitalocean_droplet.mattermost_db.ipv4_address}"
  }
}

resource "null_resource" "configure_db" {
  count = 1

  triggers = {
    template = "${data.template_file.mattermost_mysql_cf.rendered}"
  }

  # provide some connection info
  connection {
    user  = "root"
    agent = true
    host  = "${digitalocean_droplet.mattermost_db.ipv4_address}"
  }

  provisioner "file" {
    content     = "${data.template_file.mattermost_mysql_cf.rendered}"
    destination = "/etc/mysql/my.cnf"
  }

  provisioner "remote-exec" {
    inline = [
      "service mysql restart"
    ]
  }
}

resource "digitalocean_droplet" "mattermost_server" {
  name               = "${format(var.hostname_format, var.hostname_server)}"
  region             = "${var.region}"
  image              = "${var.image}"
  size               = "${var.size}"
  backups            = false
  private_networking = true
  ssh_keys           = "${var.digitalocean_ssh_keys}"

  count = 1

  provisioner "remote-exec" {
    inline = [
      "until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",
      "apt-get update",
      "apt-get install -y nginx"
    ]
  }

  provisioner "remote-exec" {
    script = "scripts/install-mattermost.sh"
  }

  provisioner "file" {
    content     = "${file("templates/mattermost.service.tpl")}"
    destination = "/lib/systemd/system/mattermost.service"
  }
}

data "template_file" "mattermost_server_config" {
  template = "${file("templates/mattermost_config.json.tpl")}"

  vars {
    mattermost_db     = "${digitalocean_droplet.mattermost_db.ipv4_address}"
    mattermost_server = "${digitalocean_droplet.mattermost_server.ipv4_address}"
  }
}

data "template_file" "mattermost_server_config_nginx" {
  template = "${file("templates/mattermost_nginx.tpl")}"

  vars {
    mattermost_server = "${digitalocean_droplet.mattermost_server.ipv4_address}"
  }
}

resource "null_resource" "configure_server" {
  triggers = {
    template = "${data.template_file.mattermost_server_config.rendered}"
    template = "${data.template_file.mattermost_server_config_nginx.rendered}"
  }

  # provide some connection info
  connection {
    user  = "root"
    agent = true
    host  = "${digitalocean_droplet.mattermost_server.ipv4_address}"
  }

  provisioner "file" {
    content     = "${data.template_file.mattermost_server_config.rendered}"
    destination = "/opt/mattermost/config/config.json"
  }

  provisioner "file" {
    content     = "${data.template_file.mattermost_server_config_nginx.rendered}"
    destination = "/etc/nginx/sites-available/mattermost"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost",
      "systemctl daemon-reload",
      "systemctl start mattermost.service",
      "systemctl enable mattermost.service",
      "systemctl restart nginx"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "cd /opt/mattermost/bin",
      "./platform user create --system_admin --email ${var.mattermost_admin_email} --username ${var.mattermost_admin_username} --password ${var.mattermost_admin_password} > 1.txt",
      "./platform team create --name ${var.mattermost_initial_teamname} --display_name \"${var.mattermost_initial_display_teamname}\" --email ${var.mattermost_admin_email}",
      "./platform team add ${var.mattermost_initial_teamname} ${var.mattermost_admin_email} ${var.mattermost_admin_username}",
    ]
  }

}

module "dns" {
  source = "./dns/cloudflare"

  count      = "1"
  email      = "${var.cloudflare_email}"
  token      = "${var.cloudflare_token}"
  domain     = "${var.domain}"
  public_ip  = "${digitalocean_droplet.mattermost_server.ipv4_address}"
  hostname   = "${digitalocean_droplet.mattermost_server.name}"
}
