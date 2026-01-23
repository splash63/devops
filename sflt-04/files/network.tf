resource "yandex_vpc_network" "develop" {
  name = "develop-fops-${var.flow}"
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-fops-${var.flow}-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_security_group" "LAN" {
  name       = "LAN-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id
  ingress {
    description    = "Allow 10.0.1.0/24"
    protocol       = "ANY"
    v4_cidr_blocks = ["10.0.1.0/24"]
    from_port      = 0
    to_port        = 65535
  }
   egress {
     description    = "Allow 10.0.1.0/24"
     protocol       = "ANY"
     v4_cidr_blocks = ["10.0.1.0/24"]
     from_port      = 0
     to_port        = 65535
   }
}

resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id


  ingress {
    description    = "Allow HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description    = "Allow my_ip any"
    protocol       = "TCP"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["85.236.178.106/32"]
  }
     egress {
     description    = "Allow 0.0.0.0/0"
     protocol       = "ANY"
     v4_cidr_blocks = ["0.0.0.0/0"]
     from_port      = 0
     to_port        = 65535
   }
}