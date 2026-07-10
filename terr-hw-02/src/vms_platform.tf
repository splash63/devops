variable "vm_web_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
}

# variable "vm_web_name" {
#   type        = string
#   default     = "netology-develop-platform-web"
# }

# variable "vm_web_cores" {
#   type        = number
#   default     = 2
# }

# variable "vm_web_memory" {
#   type        = number
#   default     = 1
# }

# variable "vm_web_core_fraction" {
#   type        = number
#   default     = 5
# }

# variable "vm_web_serial_port_enable" {
#   type        = number
#   default     = 1
# }

# variable "vm_db_cores" {
#   type        = number
#   default     = 2
# }

# variable "vm_db_memory" {
#   type        = number
#   default     = 2
# }

# variable "vm_db_core_fraction" {
#   type        = number
#   default     = 20
# }

# variable "vm_db_serial_port_enable" {
#   type        = number
#   default     = 1
# }

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
}


variable "vm_web_preemptible" {
  type        = bool
  default     = true
}

variable "vm_web_nat" {
  type        = bool
  default     = true
}

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 5
      hdd_size      = 10
      hdd_type      = "network-hdd"
    }
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      hdd_size      = 20
      hdd_type      = "network-ssd"
    }
  }
}

variable "vm_db_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
}

# variable "vm_db_name" {
#   type        = string
#   default     = "netology-develop-platform-db"
# }

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
}

variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
}

variable "vm_db_preemptible" {
  type        = bool
  default     = true
}

variable "vm_db_nat" {
  type        = bool
  default     = true
}

variable "vm_db_subnet_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "metadata" {
  type = object({
    serial-port-enable = number
    ssh-keys           = string
  })
  default = {
    "serial-port-enable" = 1
    "ssh-keys"            = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRddKVf/VjBm+cNNgAZngquvCY7yAUx8CkF48UCPfDLiei6/2t5p17uZI7GTcQ6jAwSA7CxhDlVSWOEeVoov8DrKO/stoGQY8LbbT2Y4C/Bgzy2J6xFCE/OcyD9LmBtXQOTyH3oZ5yv+pUv/A54tMXnYiE3NX4nZgUn3PrEslB5vYIQv6iuIe/hYS3XtTq3HX/Ty+RLBuNveSoySlkX5eORRAPyMbxp9E7TrA37ripJ9A02M62ezMoFJXGyVZi9TEN6d1CWAMsnCsk6cc12pTwGHLqptrrgRUz8gzUm8d6WKyEQgnSS3mTymWDOASJf7rfbcVc753lx59P8IRA9BKmEVgpOsxAsFHD4KrtQ1r9X9yikpw0ErHDmper1TYLvr2JNLiV1RFL0BCX0V0c3Tp7zB+6udqlDmgONiRA/wXpeAxc1KkHi6D91GHS55oWvdqfi5fJoYbcMTUFiwV05DxKN215VDBmrtdDV+hKUoIVZXebf3pR6312TIaoIZbHh2c= ad/gaychenkov@admin"
  }
}