import json
import uuid
from datetime import datetime

def lambda_handler(event, context):
    """
    Traite les données validées.
    Input: {"valid": true, "data": {...}, "userId": "..."}
    Output: {"processed": true, "result": {...}}
    """
    
    print(f"ProcessData received: {json.dumps(event)}")
    
    # Vérifier que les données sont valides
    if not event.get('valid', False):
        raise Exception("Cannot process invalid data")
    
    data = event['data']
    user_id = event['userId']
    
    # Simuler un traitement
    result = {
        'transactionId': str(uuid.uuid4()),
        'userId': user_id,
        'processedAt': datetime.utcnow().isoformat() + 'Z',
        'itemCount': len(data.get('items', [])),
        'status': 'completed'
    }
    
    print(f"Processing successful: {result['transactionId']}")
    return {
        'processed': True,
        'result': result
    }
