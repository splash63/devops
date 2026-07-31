terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">1.12.0"
}

provider "yandex" {
  # token                    = "do not use!!!"
  cloud_id                 = "b1g3movjjva4b0q2i3tn"
  folder_id                = "b1g1ieo1esbv688hccs9"
  service_account_key_file = file("~/.authorized_key.json")
  zone                     = "ru-central1-a" #(Optional)
}