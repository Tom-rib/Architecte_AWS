# Versions 📦

Versioning = snapshots immuables de votre fonction Lambda.

---

## 🎯 CONCEPT

```
$LATEST (développement)
  ↓
Code changes
  ↓
Publish Version 1 (snapshot)
  ↓
Code changes
  ↓
Publish Version 2 (snapshot)
```

Chaque version = immuable et peut être appelée séparément.

---

## 📌 TYPES

| Type | Mutabilité | Usage |
|------|-----------|-------|
| **$LATEST** | Mutable | Development |
| **Version** | Immuable | Production |
| **Alias** | Pointeur | Routing |

---

## ⚙️ PUBLIER VERSION

### Console

```
1. Lambda > my-api-function
2. "Versions" ▼ (en haut à droite)
3. "Publish new version"
4. Description: "v1 - Initial release"
5. Publish
```

### Voir version

```
URL ARN change:
arn:aws:lambda:eu-west-3:ACCOUNT:function:my-api-function:1
                                                           ↑
                                                    Version number
```

### CLI

```bash
aws lambda publish-version \
  --function-name my-api-function \
  --description "Release v1 - Initial API" \
  --region eu-west-3
```

---

## 🗂️ LISTER VERSIONS

### Console

```
1. Lambda > my-api-function > Versions
2. Voir liste de toutes les versions
```

### CLI

```bash
aws lambda list-versions-by-function \
  --function-name my-api-function \
  --region eu-west-3
```

**Output :**
```
{
  'Versions': [
    {'Version': '$LATEST', 'LastModified': '2024-12-26T10:00:00Z', ...},
    {'Version': '1', 'LastModified': '2024-12-26T09:00:00Z', ...},
    {'Version': '2', 'LastModified': '2024-12-25T14:00:00Z', ...},
  ]
}
```

---

## 📋 UTILISER VERSIONS

### Appeler version spécifique (CLI)

```bash
aws lambda invoke \
  --function-name my-api-function:1 \
  --payload file://event.json \
  response.json \
  --region eu-west-3
```

### Appeler version (API Gateway)

Au lieu de :
```
my-api-function
```

Utiliser :
```
my-api-function:1
```

---

## 🔒 AVANTAGES VERSIONS

✅ **Immutabilité** - Version 1 jamais change
✅ **Rollback** - Revenir à ancienne version facilement
✅ **Testing** - Tester nouvelle version sans impact
✅ **Audit** - Historique complet de changements

---

[⬅️ Retour](./README.md)

---

# Aliases 🏷️

Aliases = pointeurs nommés vers versions (ex: prod, dev, staging).

---

## 🎯 CONCEPT

Au lieu d'appeler :
```
my-api-function:1
my-api-function:2
my-api-function:3
```

Utiliser :
```
my-api-function:prod     → points to v3
my-api-function:dev      → points to $LATEST
my-api-function:staging  → points to v2
```

---

## 🏷️ CRÉER ALIAS

### Console

```
1. Lambda > my-api-function
2. "Aliases" > "Create alias"
3. Name: prod
4. Description: Production environment
5. Routing configuration:
   Version: 1 (ou $LATEST)
6. Create
```

### CLI

```bash
# Créer alias prod → version 1
aws lambda create-alias \
  --function-name my-api-function \
  --name prod \
  --function-version 1 \
  --description "Production environment" \
  --region eu-west-3

# Créer alias dev → $LATEST
aws lambda create-alias \
  --function-name my-api-function \
  --name dev \
  --function-version \$LATEST \
  --description "Development (latest)" \
  --region eu-west-3
```

---

## 🔄 METTRE À JOUR ALIAS

### Changer alias vers nouvelle version

```bash
aws lambda update-alias \
  --function-name my-api-function \
  --name prod \
  --function-version 2 \
  --region eu-west-3
```

**Effet :** prod now pointe vers v2 (was v1)

---

## 🎯 UTILISER ALIAS

### API Gateway

Configuration API Gateway :
```
Integration > Lambda Function ARN:
my-api-function:prod
```

### CLI Invoke

```bash
aws lambda invoke \
  --function-name my-api-function:prod \
  response.json
```

---

## 🔀 ALIAS AVEC CANARY (Bonus)

Déploiement progressif :

```bash
aws lambda update-alias \
  --function-name my-api-function \
  --name prod \
  --function-version 2 \
  --routing-config \
    'AdditionalVersionWeights={"1"=0.1}' \
  --region eu-west-3
```

**Effet :** 90% traffic → v2, 10% → v1

---

## 📊 WORKFLOW COMPLET

```
1. Développer code
   → Test sur $LATEST
   
2. Prêt pour prod ?
   → Publish version 2
   
3. Déployer
   → Update alias:prod → v2
   
4. Problème ?
   → Rollback: Update alias:prod → v1
   
5. Garder v1 de côté
   → Pour urgence rollback
```

---

## 🎯 BONNES PRATIQUES

✅ **Aliases par stage :**
```
prod   → version stable
staging → version prochaine
dev    → $LATEST (testing)
```

✅ **Keep 2-3 versions :**
```
v5 (prod)      → alias:prod
v4 (previous)  → alias:previous
v3 (old)       → delete
```

❌ **Éviter :**
```
- Appeler directement $LATEST en production
- Garder trop de versions (disk space)
- Alias sans version (confusion)
```

---

## 📌 NOTES

- **Versions** : Immuables à jamais
- **Aliases** : Peuvent changer
- **Cost** : Gratuit illimité
- **Limit** : Max 10,000 versions/fonction

---

[⬅️ Retour](./README.md) | [➡️ Deployment](./14-Deployment.md)

