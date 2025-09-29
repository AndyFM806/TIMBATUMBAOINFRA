resource "aws_cognito_user_pool" "pool" {
  name = "${var.project}-${var.env}-userpool"
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.project}-${var.env}-appclient"
  user_pool_id = aws_cognito_user_pool.pool.id
  generate_secret = false
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  supported_identity_providers = ["COGNITO"]
  callback_urls = ["https://app.${var.root_domain}"]
  logout_urls   = ["https://app.${var.root_domain}"]
}
