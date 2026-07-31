variable "env_name" {
  type        = string
  description = "Название окружения; используется как имя сети и как часть имени подсети"
}

variable "zone" {
  type        = string
  description = "Зона доступности, в которой создаётся подсеть (например, ru-central1-a)"
}

variable "v4_cidr_blocks" {
  type        = list(string)
  description = "Список IPv4 CIDR-блоков для подсети"
}