##############################################
# AWS WAF - Protege el API Gateway HTTP
##############################################

resource "aws_wafv2_web_acl" "api_waf" {
  name        = "waf-apigateway-TTapp"
  description = "Web ACL para proteger el API Gateway de TimbaTumbaoApp"
  scope       = "REGIONAL" # Para API Gateway regional/HTTP

  default_action {
    allow {}
  }

  # Regla 1: CommonRuleSet
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rule"
      sampled_requests_enabled   = true
    }
  }

  # Regla 2: SQLi
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "sql-injection-rule"
      sampled_requests_enabled   = true
    }
  }

  # Regla 3: KnownBadInputs
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "bad-inputs-rule"
      sampled_requests_enabled   = true
    }
  }

  # Regla 4: IP Reputation
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  # Configuración general del ACL
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-apigateway-ttapp"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "waf-apigateway-TTapp"
    Environment = var.stage
  }
}

##############################################
# Asociación del WAF con el API Gateway
##############################################

# OJO: aquí supongo que tienes un módulo "api" que expone el ARN del stage
# Si aún no lo tienes, luego ajustamos esto; por ahora es sintaxis válida.

resource "aws_wafv2_web_acl_association" "api_waf_association" {
  resource_arn = module.api.api_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.api_waf.arn
}
