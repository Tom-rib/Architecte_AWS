# CORS - Activer Cross-Origin Requests 🔒

CORS = permet à un frontend JavaScript d'appeler votre API depuis un domaine différent.

---

## 🎯 PROBLÈME

Sans CORS, ce JavaScript génère erreur :

```javascript
// Frontend sur https://monsite.com
fetch('https://api.example.com/hello')
  .then(r => r.json())
  .catch(e => console.error('CORS Error:', e))
```

**Erreur console :**
```
Access to fetch at 'https://api.example.com/hello' 
from origin 'https://monsite.com' has been blocked by CORS policy
```

---

## ✅ SOLUTION : ACTIVER CORS

### Dans API Gateway Console

```
1. API Gateway > Resources > /hello
2. Sélectionner ressource
3. Actions ▼ > Enable CORS
4. Cliquer "Enable CORS and replace existing CORS headers"
5. [Confirm]
```

### Fichier de configuration CORS

Après, vous verrez :

```
┌─ /hello - OPTIONS (new method added)
├─ Method Response
├─ Integration Response
└─ Headers: Access-Control-Allow-Headers, etc
```

---

## 🔧 CONFIGURER MANUELLEMENT

Si "Enable CORS" ne marche pas, faire manuellement :

### 1. Ajouter méthode OPTIONS

```
1. Sélectionner /hello
2. Actions > Create Method > OPTIONS
3. Integration type: Mock
4. Cliquer Save
```

### 2. Ajouter headers de réponse

```
1. OPTIONS method > Method Response
2. Expand 200
3. Add Response Headers:
   - Access-Control-Allow-Headers
   - Access-Control-Allow-Methods
   - Access-Control-Allow-Origin
```

### 3. Configurer Integration Response

```
1. OPTIONS > Integration Response
2. Expand 200
3. Mapping Templates > application/json
4. Template body:
   {}
5. Response Headers: (voir ci-bas)
```

---

## 📋 HEADERS CORS COMPLETS

| Header | Valeur | Raison |
|--------|--------|--------|
| **Access-Control-Allow-Origin** | * | Tous les domaines |
| **Access-Control-Allow-Methods** | GET,POST,PUT,DELETE,OPTIONS | Méthodes autorisées |
| **Access-Control-Allow-Headers** | Content-Type,X-Amz-Date,Authorization,X-Api-Key | Headers autorisés |
| **Access-Control-Max-Age** | 7200 | Cache 2h |
| **Access-Control-Allow-Credentials** | true | Cookies acceptés |

---

## 🔐 CORS STRICT (recommandé pour prod)

Au lieu de `*`, spécifier domaine :

```
Access-Control-Allow-Origin: https://monsite.com
```

Ou plusieurs domaines (lambda function) :

```python
origin = event['headers'].get('origin', '')
allowed_origins = [
    'https://monsite.com',
    'https://app.monsite.com',
    'http://localhost:3000'
]

allow_origin = origin if origin in allowed_origins else ''

return {
    'statusCode': 200,
    'headers': {
        'Access-Control-Allow-Origin': allow_origin,
        'Content-Type': 'application/json'
    },
    'body': json.dumps({'message': 'OK'})
}
```

---

## ✅ TEST CORS

### Dans navigateur (DevTools)

```javascript
// Frontend sur localhost:3000
fetch('https://your-api.execute-api.eu-west-3.amazonaws.com/prod/hello')
  .then(response => response.json())
  .then(data => console.log('Success:', data))
  .catch(error => console.error('Error:', error));
```

**Si ✅ OK :**
```
Success: {message: "Hello World"}
```

**Si ❌ Error :**
```
Access to fetch at 'https://your-api...' 
from origin 'http://localhost:3000' 
has been blocked by CORS policy
```

---

[⬅️ Retour](./README.md) | [➡️ Troubleshooting](./15-Troubleshooting.md)

