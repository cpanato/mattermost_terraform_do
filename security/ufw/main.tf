variable "connection_db" {
  type = "string"
}

variable "connection_server" {
  type = "string"
}

variable "private_interface_db" {
  type = "string"
}

variable "private_interface_server" {
  type = "string"
}

resource "null_resource" "firewall-db" {
  triggers = {
    template = "${data.template_file.ufw_db.rendered}"
  }

  connection {
    host  = "${var.connection_db}"
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = <<EOF
${data.template_file.ufw_db.rendered}
EOF
  }
}

data "template_file" "ufw_db" {
  template = "${file("${path.module}/scripts/ufw_db.sh")}"

  vars {
    private_interface = "${var.private_interface_db}"
    mattermost_server = "${var.connection_server}"
  }
}


resource "null_resource" "firewall-server" {
  triggers = {
    template = "${data.template_file.ufw_server.rendered}"
  }

  connection {
    host  = "${var.connection_server}"
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = <<EOF
${data.template_file.ufw_server.rendered}
EOF
  }
}

data "template_file" "ufw_server" {
  template = "${file("${path.module}/scripts/ufw_server.sh")}"

  vars {
    private_interface = "${var.private_interface_server}"
    mattermost_db = "${var.connection_db}"
  }
}
