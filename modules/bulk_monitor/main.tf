terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.26.0"
    }
  }
}

locals {
data = csvdecode(file(var.filepath))
}


resource "datadog_synthetics_test" "datadog" {

for_each = { for inst in local.data : inst.project => inst }

  type    = "api"
  subtype = "http"
  name    = each.value.subject
  message = <<EOF
@${each.value.email},

${each.value.message}.
EOF

  tags    = split(",", each.value.tags)
  #tags = ["account_name:${each.value.project}","env:${each.value.env}","${each.value.tags}"]
  status = "live"

  request_definition {
    method = "GET"
    url    = each.value.url
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = each.value.status_code
  }

  assertion {
    type     = "responseTime"
    operator = "lessThan"
    target   = each.value.latency_kpi
  }


  locations = ["aws:us-east-1"]
  options_list {
    tick_every          = each.value.test_interval
    retry {
      count    = each.value.retry_attempts
      interval = 300
    }
    min_location_failed = 1
    monitor_priority = each.value.priority
    monitor_name     = "${each.value.project}/${each.value.env}/${each.value.subject}"
  }

}
