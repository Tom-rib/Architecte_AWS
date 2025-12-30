import json

def lambda_handler(event, context):
    """
    Valide les données d'entrée du workflow.
    Input: {"data": {...}, "userId": "..."}
    Output: {"valid": true/false, "data": {...}, "errors": [...]}
    """
    
    print(f"ValidateInput received: {json.dumps(event)}")
    
    errors = []
    
    # Vérifier que 'data' existe
    if 'data' not in event:
        errors.append("Missing 'data' field")
    
    # Vérifier que 'userId' existe
    if 'userId' not in event:
        errors.append("Missing 'userId' field")
    
    # Retourner le résultat
    if errors:
        print(f"Validation failed: {errors}")
        raise Exception(f"Validation failed: {', '.join(errors)}")
    
    print("Validation successful")
    return {
        'valid': True,
        'data': event['data'],
        'userId': event['userId']
    }
