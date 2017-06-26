/* DO SSH */
variable "token" {}

variable "ssh_keys" {
  type = "list"
}

/* Server */
variable "db_region" {
  type    = "string"
  default = "fra1"
}

variable "db_image" {
  type    = "string"
  default = "ubuntu-16-04-x64"
}

variable "db_size" {
  type    = "string"
  default = "1gb"
}

variable "hostname_format" {
  default = "mattermost-%s"
}

variable "hostname_database" {
  type = "string"
  default = "db"
}

/* Database */
variable "db_root_password" {
  description = "Password for the root db"
}

