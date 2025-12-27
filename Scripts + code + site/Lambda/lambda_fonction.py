import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        # REST API envoie httpMethod et path
        method = event.get('httpMethod', 'GET')
        path = event.get('path', '/')
        
        # Query parameters
        query_params = event.get('queryStringParameters') or {}
        name = query_params.get('name', 'World')
        
        # Message
        message = f"Hello {name}! Method: {method}, Path: {path}"
        logger.info(f"Requête: {method} {path}, Nom: {name}")
        
        # Response
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'message': message,
                'method': method,
                'path': path
            })
        }
        
    except Exception as e:
        logger.error(f"Erreur: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }