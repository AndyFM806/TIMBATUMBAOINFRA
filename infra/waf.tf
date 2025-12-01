resource "aws_wafv2_web_acl" "api_gateway_waf" {
  name        = "timbatumbao-api-gateway-waf"
  description = "WAF for Timbatumbao API Gateway"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Regla para bloquear inyecciones SQL
  rule {
    name     = "SQLiRule"
    priority = 1

    action {
      block {}
    }

    statement {
      sqli_match_statement {
        field_to_match {
          all_query_arguments {}
        }
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "timbatumbao-SQLiRule"
      sampled_requests_enabled   = true
    }
  }

  # Regla para bloquear ataques XSS
  rule {
    name     = "XSSRule"
    priority = 2

    action {
      block {}
    }

    statement {
      xss_match_statement {
        field_to_match {
          all_query_arguments {}
        }
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "timbatumbao-XSSRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "timbatumbao-api-gateway-waf"
    sampled_requests_enabled   = true
  }
}
