variable "count" {}

variable "email" {}

variable "token" {}

variable "domain" {}

variable "hostname" {
  type = "string"
}

variable "public_ip" {
  type = "string"
}

provider "cloudflare" {
  email = "${var.email}"
  token = "${var.token}"
}

resource "cloudflare_record" "hosts" {
  domain  = "${var.domain}"
  name    = "${var.hostname}"
  value   = "${var.public_ip}"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "domain" {
  domain  = "${var.domain}"
  name    = "${var.domain}"
  value   = "${var.public_ip}"
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "wildcard" {
  depends_on = ["cloudflare_record.domain"]

  domain  = "${var.domain}"
  name    = "mattermost"
  value   = "${var.domain}"
  type    = "CNAME"
  proxied = false
}

output "domains" {
  value = ["${cloudflare_record.hosts.*.hostname}"]
}
