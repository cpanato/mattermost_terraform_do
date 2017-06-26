provider "digitalocean" {
  token = "${var.token}"
}

resource "digitalocean_droplet" "mattermost_server" {
  name               = "${format(var.hostname_format, var.hostname_server)}"
  region             = "${var.server_region}"
  image              = "${var.server_image}"
  size               = "${var.server_size}"
  backups            = false
  private_networking = true
  ssh_keys           = "${var.ssh_keys}"

  provisioner "remote-exec" {
    inline = [
      "until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",
      "apt-get update",
      "apt-get install -y nginx"
    ]
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/install-mattermost.sh"
  }

  provisioner "file" {
    content     = "${file("${path.module}/templates/mattermost.service.tpl")}"
    destination = "/lib/systemd/system/mattermost.service"
  }
}

data "template_file" "mattermost_server_config" {
  template = "${file("${path.module}/templates/mattermost_config.json.tpl")}"

  vars {
    mattermost_db     = "${var.mattermost_db_ip}"
    mattermost_server = "${digitalocean_droplet.mattermost_server.ipv4_address}"
  }
}

data "template_file" "mattermost_server_config_nginx" {
  template = "${file("${path.module}/templates/mattermost_nginx.tpl")}"

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
      "systemctl enable mattermost.service"
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
