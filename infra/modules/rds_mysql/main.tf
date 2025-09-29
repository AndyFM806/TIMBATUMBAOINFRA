resource "aws_db_subnet_group" "db" {
  name       = "${var.project}-${var.env}-dbsubnets"
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "db" {
  name   = "${var.project}-${var.env}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "RDS Proxy -> DB"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.proxy.id]
  }
}

resource "aws_db_instance" "mysql" {
  identifier              = "${var.project}-${var.env}-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.db.name
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
}

# SG para RDS Proxy (acepta de Lambdas)
resource "aws_security_group" "proxy" {
  name   = "${var.project}-${var.env}-rds-proxy-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Lambda -> Proxy"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.lambda_sg_id]
  }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

# Secret para credenciales de DB (para auth del Proxy)
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.project}/${var.env}/db"
}
resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({ username = var.db_username, password = var.db_password })
}

resource "aws_db_proxy" "proxy" {
  name                   = "${var.project}-${var.env}-proxy"
  engine_family          = "MYSQL"
  role_arn               = "arn:aws:iam::aws:policy/service-role/AmazonRDSProxyServiceRole" # usa rol administrado de la cuenta si lo tienes; si no, crea uno
  vpc_security_group_ids = [aws_security_group.proxy.id]
  vpc_subnet_ids         = var.private_subnets
  require_tls            = true

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.db_secret.arn
    iam_auth    = "DISABLED"
  }
}

resource "aws_db_proxy_target" "proxy_target" {
  db_proxy_name = aws_db_proxy.proxy.name
  target_group_name = "default"
  db_instance_identifier = aws_db_instance.mysql.id
}
