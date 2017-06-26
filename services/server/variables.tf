/* DO SSH */
variable "token" {}

variable "ssh_keys" {
  type = "list"
}

/* Server */
variable "server_region" {
  type    = "string"
  default = "fra1"
}

variable "server_image" {
  type    = "string"
  default = "ubuntu-16-04-x64"
}

variable "server_size" {
  type    = "string"
  default = "1gb"
}

variable "hostname_format" {
  default = "mattermost-%s"
}

variable "hostname_server" {
  type = "string"
  default = "server"
}

/*  Mattermost */
variable "mattermost_admin_email"{
  type = "string"
  default = ""
}

variable "mattermost_admin_username"{
  type = "string"
  default = ""
}

variable "mattermost_admin_password"{
  type = "string"
  default = ""
}

variable "mattermost_initial_teamname"{
  type = "string"
  default = ""
}

variable "mattermost_initial_display_teamname"{
  type = "string"
  default = ""
}

variable "mattermost_db_ip" {
  type = "string"
}
