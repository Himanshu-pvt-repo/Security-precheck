output "datadog_api_key" {
  value = datadog_api_key.api.key
  sensitive = true
}
