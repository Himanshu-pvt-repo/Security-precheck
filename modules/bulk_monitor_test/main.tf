#locals {
#data = csvdecode(file("monitor"))
#}

#output "data"{
#value = local.data
#}


locals {
  data = csvdecode(file("monitor"))
  tag_values = [for item in local.data : item.tags]
  tags_list = flatten([for tags in local.tag_values : split(",", tags)])
}

output "tag_values" {
  value = local.tags_list
}

