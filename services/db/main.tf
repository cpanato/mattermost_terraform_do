provider "digitalocean" {
  token = "${var.token}"
}

resource "digitalocean_droplet" "mattermost_db" {
  name               = "${format(var.hostname_format, var.hostname_database)}"
  region             = "${var.db_region}"
  image              = "${var.db_image}"
  size               = "${var.db_size}"
  backups            = false
  private_networking = true
  ssh_keys           = "${var.ssh_keys}"

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
  template = "${file("${path.module}/templates/my.cnf.tpl")}"

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