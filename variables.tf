/* general */
variable "hostname_format" {
  default = "mattermost-%s"
}

variable "hostname_database" {
  type = "string"
  default = "db"
}

variable "hostname_server" {
  type = "string"
  default = "server"
}

variable "domain" {
  default = "undergroundtest.tech"
}

/* cloudflare */
variable "cloudflare_email" {
  default = ""
}

variable "cloudflare_token" {
  default = ""
}

/* digitalocean */
variable "token" {}

variable "digitalocean_ssh_keys" {
  default = []
}

/*  Mattermost */
variable "mattermost_admin_email"{
  default = "joe@example.com"
}

variable "mattermost_admin_username"{
  default = "joe"
}

variable "mattermost_admin_password"{
  default = "Password1"
}

variable "mattermost_initial_teamname"{
  default = "newteamdo"
}

variable "mattermost_initial_display_teamname"{
  default = "DO Terraform"
}
