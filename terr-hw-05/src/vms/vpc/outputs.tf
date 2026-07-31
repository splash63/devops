output "subnet" {
  description = "Полный объект созданной подсети (yandex_vpc_subnet)"
  value       = yandex_vpc_subnet.this
}

output "subnet_id" {
  description = "ID созданной подсети"
  value       = yandex_vpc_subnet.this.id
}

output "network_id" {
  description = "ID сети, в которой создана подсеть"
  value       = yandex_vpc_network.this.id
}