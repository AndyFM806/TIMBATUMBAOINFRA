output "api_invoke_url"     { value = module.api_gw.invoke_url }
output "cf_domain_name"     { value = module.s3_cloudfront.cf_domain }
output "user_pool_id"       { value = module.cognito.user_pool_id }
output "rds_endpoint"       { value = module.rds_mysql.rds_endpoint }
output "rds_proxy_endpoint" { value = module.rds_mysql.proxy_endpoint }
