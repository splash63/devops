resource "yandex_storage_bucket" "web" {
  bucket_prefix = "lamp-lab-"
  folder_id     = var.folder_id

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

resource "yandex_storage_object" "picture" {
  bucket       = yandex_storage_bucket.web.bucket
  key          = "lamp.png"
  source       = "${path.module}/assets/lamp.png"
  source_hash  = filemd5("${path.module}/assets/lamp.png")
  content_type = "image/png"
}

locals {
  picture_url = "https://storage.yandexcloud.net/${yandex_storage_object.picture.bucket}/${yandex_storage_object.picture.key}"
}

output "picture_url" {
  value = local.picture_url
}
