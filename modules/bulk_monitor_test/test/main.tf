variable "tags_string" {
  default = "tag1:value1,tag2:value2"
}

locals {
  tags_list = split(",", var.tags_string)
}

output "formatted_tags" {
  value = local.tags_list
}
