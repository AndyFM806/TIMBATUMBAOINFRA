
# infra/networking.tf

# VPC: Contenedor principal de la red
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tapp-vpc"
  }
}

# Subred Pública: Para recursos con acceso a Internet (ej. NAT Gateway)
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Se puede parametrizar si es necesario

  map_public_ip_on_launch = false

  tags = {
    Name = "tapp-subnet-public"
  }
}

# Subred Privada: Para recursos sin acceso directo desde Internet (ej. Lambdas)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a" # Idealmente, usar una AZ diferente en producción real

  tags = {
    Name = "tapp-subnet-private"
  }
}

# Internet Gateway: Permite la comunicación entre la VPC e Internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tapp-igw"
  }
}

# Elastic IP: IP pública fija para la NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "tapp-nat-eip"
  }
}

# NAT Gateway: Permite a los recursos en subredes privadas acceder a Internet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "tapp-nat-gw"
  }

  # La NAT Gateway depende de que el Internet Gateway esté conectado
  depends_on = [aws_internet_gateway.main]
}

# --- Tablas de Rutas ---

# Tabla de Rutas para la Subred Pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Ruta por defecto a Internet
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "tapp-rt-public"
  }
}

# Tabla de Rutas para la Subred Privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0" # Ruta por defecto a la NAT Gateway
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "tapp-rt-private"
  }
}

# --- Asociaciones de Rutas ---

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# --- Default Security Group: Restrict all traffic by default ---
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "tapp-default-sg"
  }
}

# --- VPC Flow Logs ---
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "tapp-vpc-flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.encryption_key.arn # Re-using existing KMS key for encryption
}

resource "aws_iam_role" "flow_logs_role" {
  name = "tapp-flow-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

# Grupo de seguridad para el VPC Endpoint de CloudWatch
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Allow TLS traffic for VPC endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

# VPC Endpoint para CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "logs-vpc-endpoint"
  }
}
