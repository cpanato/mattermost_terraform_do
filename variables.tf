/* general */
variable "hostname_format" {
  default = "mattermost-%s"
}

variable "domain" {
  default = "example.com"
}

/* cloudflare */
variable "cloudflare_email" {
  default = ""
}

variable "cloudflare_token" {
  default = ""
}

/* digitalocean */

variable "digitalocean_ssh_keys" {
  default = []
}

variable "digitalocean_region" {
  default = "nyc1"
}

variable "token" {}

variable "hostname_database" {
  type = "string"
  default = "db"
}

variable "hostname_server" {
  type = "string"
  default = "server"
}

variable "region" {
  type    = "string"
  default = "fra1"
}

variable "image" {
  type    = "string"
  default = "ubuntu-16-04-x64"
}

variable "size" {
  type    = "string"
  default = "1gb"
}

/* Database */
variable "db_root_password" {
  default = "root"
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
