import json
import os
import boto3
import uuid
from datetime import datetime

# Variables de entorno
DYNAMODB_TABLE_NAME = os.environ.get("DYNAMODB_TABLE_NAME")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

# Verificación de variables de entorno
if not all([DYNAMODB_TABLE_NAME, SNS_TOPIC_ARN]):
    raise Exception("Las variables de entorno DYNAMODB_TABLE_NAME y SNS_TOPIC_ARN son requeridas.")

# Clientes de AWS
dynamodb_resource = boto3.resource("dynamodb")
sns_client = boto3.client("sns")
table = dynamodb_resource.Table(DYNAMODB_TABLE_NAME)

def lambda_handler(event, context):
    """
    Procesa mensajes de la cola de pagos de SQS.
    - Procesa el pago (simulado).
    - Actualiza la tabla DynamoDB con el estado de la inscripción.
    - Envía una notificación a un tema SNS.
    """
    print(f"Evento SQS recibido: {json.dumps(event)}")

    for record in event["Records"]:
        try:
            message_body = json.loads(record["body"])
            enrollment_id = message_body["enrollmentId"]
            student_id = message_body["studentId"]
            class_id = message_body["classId"]
            amount = message_body["amount"]

            # 1. Simulación de procesamiento de pago
            print(f"Procesando pago de {amount} para la inscripción {enrollment_id}...")
            payment_successful = True  # Simulación; aquí iría la lógica real con una pasarela de pago.
            payment_id = f"PAY-{uuid.uuid4()}"

            if payment_successful:
                # 2. Actualizar DynamoDB si el pago es exitoso
                print("Pago exitoso. Actualizando base de datos...")
                table.put_item(
                    Item={
                        "PK": f"STUDENT#{student_id}",
                        "SK": f"ENROLLMENT#{enrollment_id}",
                        "classId": class_id,
                        "paymentId": payment_id,
                        "amountPaid": str(amount),
                        "status": "CONFIRMED",
                        "enrollmentDate": datetime.utcnow().isoformat()
                    }
                )

                # 3. Enviar notificación de éxito a SNS
                print("Enviando notificación de éxito...")
                sns_client.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Subject="¡Inscripción Confirmada en Timbatumbao!",
                    Message=f"¡Felicidades! Tu inscripción a la clase '{class_id}' ha sido confirmada. ID de pago: {payment_id}.",
                    MessageAttributes={
                        "studentId": {"DataType": "String", "StringValue": student_id},
                        "status": {"DataType": "String", "StringValue": "SUCCESS"}
                    }
                )
            else:
                # Lógica para pago fallido
                print("El pago falló. Enviando notificación de error...")
                sns_client.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Subject="Problema con tu inscripción en Timbatumbao",
                    Message=f"Lo sentimos, hubo un problema al procesar el pago para la clase '{class_id}'. Por favor, inténtalo de nuevo.",
                    MessageAttributes={
                        "studentId": {"DataType": "String", "StringValue": student_id},
                        "status": {"DataType": "String", "StringValue": "FAILURE"}
                    }
                )

        except Exception as e:
            print(f"Error procesando el mensaje: {str(e)}. Mensaje original: {record['body']}")
            # Aquí se podría mover el mensaje a una DLQ
            continue
            
    return {"status": "Procesamiento completado"}