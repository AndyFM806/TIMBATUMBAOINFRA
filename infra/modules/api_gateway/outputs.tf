output "invoke_url" { value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.env}" }
output "stage_arn"  { value = aws_api_gateway_stage.stage.arn }

data "aws_region" "current" {}
output "rest_api_id" { value = aws_api_gateway_rest_api.api.id }
