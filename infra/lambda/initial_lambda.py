import json
import os
import boto3
import uuid

# Obtener la URL de la cola SQS desde las variables de entorno
PAYMENT_QUEUE_URL = os.environ.get("PAYMENT_QUEUE_URL")
if not PAYMENT_QUEUE_URL:
    raise Exception("La variable de entorno PAYMENT_QUEUE_URL no está configurada.")

sqs_client = boto3.client("sqs")

def lambda_handler(event, context):
    """
    Manejador del Lambda que recibe las solicitudes de inscripción.
    Valida los datos de entrada y los envía a una cola SQS para procesamiento asíncrono.
    """
    print(f"Evento recibido: {json.dumps(event)}")

    try:
        # El cuerpo de la petición puede venir anidado bajo un proxy de API Gateway
        body_str = event.get("body", "{}")
        body = json.loads(body_str if body_str else "{}")
        
        student_id = body.get("studentId")
        class_id = body.get("classId")
        amount = body.get("amount")

        if not all([student_id, class_id, amount]):
            return {
                "statusCode": 400,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"message": "Faltan datos en la solicitud: se requiere studentId, classId y amount."})
            }

        # Crear el mensaje para la cola
        message_body = {
            "enrollmentId": str(uuid.uuid4()),
            "studentId": student_id,
            "classId": class_id,
            "amount": amount,
            "requestTimestamp": context.aws_request_id
        }

        # Enviar el mensaje a la cola SQS
        sqs_client.send_message(
            QueueUrl=PAYMENT_QUEUE_URL,
            MessageBody=json.dumps(message_body)
        )

        print(f"Mensaje de inscripción enviado a la cola: {json.dumps(message_body)}")

        # Responder inmediatamente al usuario
        return {
            "statusCode": 202, # Accepted
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Inscripción en proceso. Recibirás una confirmación pronto."})
        }

    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Cuerpo de la solicitud mal formado (no es un JSON válido)."})
        }
    except Exception as e:
        print(f"Error inesperado: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Error interno del servidor."})
        }
