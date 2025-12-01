# App/lambdas/notificaciones/main.py
import json

def handler(event, context):
    """
    Lambda para procesar notificaciones de pago desde un tema de SNS.
    Simula el envío de un correo electrónico de confirmación.
    """
    print("LambdaNotificaciones ejecutada.")
    
    # El 'event' de una invocación de SNS contiene una lista de 'Records'.
    for record in event['Records']:
        # El mensaje de SNS está en el campo 'Sns'.
        sns_message_str = record['Sns']['Message']
        print(f"Mensaje SNS recibido: {sns_message_str}")
        
        try:
            # El mensaje que enviamos desde LambdaInscripciones era una cadena JSON.
            # Lo parseamos para acceder a los datos.
            message_data = json.loads(sns_message_str)
            
            user_email = message_data.get('email', 'no-email-provided')
            inscription_id = message_data.get('inscriptionId', 'no-id-provided')
            status = message_data.get('status', 'no-status-provided')
            
            # Simulación de envío de correo electrónico con Amazon SES
            print(f"Simulando envío de correo a: {user_email}")
            print(f"Asunto: Confirmación de tu inscripción (ID: {inscription_id})")
            print(f"Cuerpo: Hola, tu inscripción ha sido procesada con estado: '{status}'. ¡Gracias por unirte!")
            
            print("Correo de simulación enviado exitosamente.")
        
        except json.JSONDecodeError:
            print(f"Error: El mensaje SNS no es un JSON válido: {sns_message_str}")
        except Exception as e:
            print(f"Error procesando el mensaje: {str(e)}")

    return {
        'statusCode': 200,
        'body': json.dumps('Procesamiento de notificaciones completado.')
    }
