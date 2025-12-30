import json

def lambda_handler(event, context):
    """
    Envoie une notification de fin de traitement.
    Input: {"processed": true, "result": {...}}
    Output: {"notified": true, "message": "..."}
    """
    
    print(f"SendNotification received: {json.dumps(event)}")
    
    if not event.get('processed', False):
        raise Exception("Cannot notify: data was not processed")
    
    result = event['result']
    
    # Simuler l'envoi de notification
    message = f"Transaction {result['transactionId']} completed for user {result['userId']}"
    
    print(f"Notification sent: {message}")
    return {
        'notified': True,
        'message': message,
        'transactionId': result['transactionId']
    }
