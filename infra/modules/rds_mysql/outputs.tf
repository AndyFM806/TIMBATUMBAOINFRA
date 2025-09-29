output "rds_endpoint"   { value = aws_db_instance.mysql.address }
output "proxy_endpoint" { value = aws_db_proxy.proxy.endpoint }
output "rds_arn"        { value = aws_db_instance.mysql.arn }
