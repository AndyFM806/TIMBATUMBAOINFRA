# Configura el proveedor de AWS y la región donde se desplegarán los recursos
provider "aws" {
    region = variables.aws_region
}

# Crea un rol de IAM para la función Lambda, permitiendo que Lambda asuma este rol
resource "aws_iam_role" "lambda_role" {
    name = "inscripciones_lambda_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com" # Permite que el servicio Lambda asuma el rol
            }
        }]
    })
}

# Adjunta la política básica de ejecución de Lambda al rol creado
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # Permite a Lambda escribir logs en CloudWatch
}

# Crea la función Lambda
resource "aws_lambda_function" "inscripciones" {
    function_name = "inscripciones_lambda" # Nombre de la función Lambda
    handler       = "index.handler"        # Punto de entrada del código Lambda
    runtime       = "nodejs18.x"           # Runtime de Node.js 18.x

    filename         = "lambda_function_payload.zip"           # Archivo ZIP con el código fuente de la Lambda
    source_code_hash = filebase64sha256("lambda_function_payload.zip") # Hash para detectar cambios en el código

    role = aws_iam_role.lambda_role.arn # Rol de IAM que usará la función Lambda

    environment {
        variables = {
            # Aquí puedes definir variables de entorno para la función Lambda, por ejemplo:
            # DB_TABLE = "inscripciones"
        }
    }
}

# Output que muestra el nombre de la función Lambda creada
output "lambda_function_name" {
    value = aws_lambda_function.inscripciones.function_name
}