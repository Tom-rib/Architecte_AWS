# Job 2 : S3 + CloudFront 🌐

> Héberger un site web statique avec distribution mondiale

---

## 🎯 Objectif

Héberger un site web statique (HTML, CSS, JavaScript) en utilisant S3 et distribuer le contenu globalement avec CloudFront pour une meilleure performance et sécurité.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| S3 | Stockage des fichiers statiques |
| CloudFront | CDN (200+ serveurs mondiaux) |
| IAM | Gestion des permissions |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| S3 | 5 GB stockage gratuit |
| CloudFront | 1 TB transfert gratuit |

✅ **Entièrement gratuit pour ce projet**

---

# Étape 1 : Créer un Bucket S3

## 🖥️ Dashboard

```
1. S3 → Buckets → Create bucket

2. Bucket name : mon-site-2024-votreprenom
   ⚠️ Doit être unique au monde !

3. Region : eu-west-3 (Paris)

4. Object Ownership : ACLs disabled (recommandé)

5. Block Public Access settings :
   ☐ DÉCOCHEZ "Block all public access"
   ☑ Cochez "I acknowledge..."

6. Bucket Versioning : Disable

7. Default encryption : SSE-S3

8. Create bucket ✓
```

## 💻 CLI

```bash
# Créer le bucket
aws s3api create-bucket \
  --bucket mon-site-2024-tom \
  --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3

# Désactiver le blocage d'accès public
aws s3api put-public-access-block \
  --bucket mon-site-2024-tom \
  --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

---

# Étape 2 : Uploader les fichiers

## 📄 Fichiers à préparer

Créez ces fichiers localement :

### index.html

```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mon Site AWS</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>🚀 Bienvenue sur mon site AWS !</h1>
        <p>Ce site est hébergé sur Amazon S3 et distribué via CloudFront.</p>
        <div class="features">
            <div class="feature">
                <h3>📦 S3</h3>
                <p>Stockage fiable et sécurisé</p>
            </div>
            <div class="feature">
                <h3>🌍 CloudFront</h3>
                <p>Distribution mondiale rapide</p>
            </div>
            <div class="feature">
                <h3>🔒 HTTPS</h3>
                <p>Connexion sécurisée</p>
            </div>
        </div>
    </div>
    <script src="app.js"></script>
</body>
</html>
```

### styles.css

```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Arial, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}

.container {
    background: white;
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    text-align: center;
    max-width: 800px;
}

h1 {
    color: #333;
    margin-bottom: 20px;
}

p {
    color: #666;
    font-size: 1.1em;
}

.features {
    display: flex;
    justify-content: space-around;
    margin-top: 30px;
    flex-wrap: wrap;
    gap: 20px;
}

.feature {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    padding: 20px;
    border-radius: 10px;
    flex: 1;
    min-width: 150px;
}

.feature h3 {
    margin-bottom: 10px;
}
```

### error.html

```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Erreur 404</title>
    <style>
        body { 
            font-family: Arial; 
            text-align: center; 
            padding: 50px;
            background: #f0f0f0;
        }
        h1 { color: #e74c3c; }
    </style>
</head>
<body>
    <h1>404 - Page non trouvée</h1>
    <p>La page que vous cherchez n'existe pas.</p>
    <a href="/">Retour à l'accueil</a>
</body>
</html>
```

## 🖥️ Dashboard

```
1. S3 → Buckets → mon-site-2024-tom

2. Upload → Add files
   - Sélectionnez : index.html, styles.css, error.html

3. Upload ✓
```

## 💻 CLI

```bash
# Upload tous les fichiers
aws s3 cp index.html s3://mon-site-2024-tom/
aws s3 cp styles.css s3://mon-site-2024-tom/
aws s3 cp error.html s3://mon-site-2024-tom/

# Ou sync un dossier entier
aws s3 sync ./mon-site/ s3://mon-site-2024-tom/
```

---

# Étape 3 : Configurer les Permissions

## 🖥️ Dashboard

```
1. S3 → Buckets → mon-site-2024-tom

2. Onglet "Permissions"

3. Bucket policy → Edit

4. Collez cette policy :
```

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::mon-site-2024-tom/*"
        }
    ]
}
```

⚠️ **Remplacez `mon-site-2024-tom` par votre nom de bucket !**

```
5. Save changes ✓
```

## 💻 CLI

```bash
# Créer le fichier policy.json
cat > policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::mon-site-2024-tom/*"
        }
    ]
}
EOF

# Appliquer la policy
aws s3api put-bucket-policy \
  --bucket mon-site-2024-tom \
  --policy file://policy.json
```

---

# Étape 4 : Activer l'hébergement statique

## 🖥️ Dashboard

```
1. S3 → Buckets → mon-site-2024-tom

2. Onglet "Properties"

3. Static website hosting → Edit

4. Static website hosting : Enable

5. Hosting type : Host a static website

6. Index document : index.html

7. Error document : error.html

8. Save changes ✓

9. Notez l'URL affichée :
   http://mon-site-2024-tom.s3-website.eu-west-3.amazonaws.com
```

## 💻 CLI

```bash
# Activer l'hébergement statique
aws s3 website s3://mon-site-2024-tom/ \
  --index-document index.html \
  --error-document error.html

# L'URL sera :
# http://mon-site-2024-tom.s3-website.eu-west-3.amazonaws.com
```

## ✅ Test

Ouvrez l'URL S3 dans votre navigateur. Le site doit s'afficher !

---

# Étape 5 : Créer une distribution CloudFront

## 🖥️ Dashboard

```
1. CloudFront → Distributions → Create distribution

2. Origin domain : 
   Sélectionnez : mon-site-2024-tom.s3.eu-west-3.amazonaws.com
   ⚠️ PAS le s3-website-... !

3. Origin access :
   - Origin access control settings (recommended)
   - Create new OAC → Create

4. Default cache behavior :
   - Viewer protocol policy : Redirect HTTP to HTTPS
   - Allowed HTTP methods : GET, HEAD
   - Cache policy : CachingOptimized

5. Settings :
   - Price class : Use all edge locations
   - Default root object : index.html

6. Create distribution ✓

7. ⚠️ Une bannière jaune apparaît :
   "The S3 bucket policy needs to be updated"
   → Cliquez "Copy policy"
```

### Mettre à jour la Bucket Policy pour CloudFront

```
1. S3 → Buckets → mon-site-2024-tom
2. Permissions → Bucket policy → Edit
3. Remplacez par la policy copiée depuis CloudFront
4. Save changes ✓
```

## 💻 CLI

```bash
# Créer l'Origin Access Control
OAC_ID=$(aws cloudfront create-origin-access-control \
  --origin-access-control-config '{
    "Name": "S3-OAC",
    "Description": "OAC for S3",
    "SigningProtocol": "sigv4",
    "SigningBehavior": "always",
    "OriginAccessControlOriginType": "s3"
  }' \
  --query 'OriginAccessControl.Id' \
  --output text)

# Créer la distribution CloudFront
aws cloudfront create-distribution \
  --distribution-config '{
    "CallerReference": "mon-site-2024",
    "Origins": {
      "Quantity": 1,
      "Items": [{
        "Id": "S3-mon-site",
        "DomainName": "mon-site-2024-tom.s3.eu-west-3.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        },
        "OriginAccessControlId": "'$OAC_ID'"
      }]
    },
    "DefaultCacheBehavior": {
      "TargetOriginId": "S3-mon-site",
      "ViewerProtocolPolicy": "redirect-to-https",
      "AllowedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      },
      "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
      "Compress": true
    },
    "DefaultRootObject": "index.html",
    "Enabled": true,
    "Comment": "Distribution pour mon site statique"
  }'
```

---

# Étape 6 : Tester et invalider le cache

## ⏳ Attendre le déploiement

```
1. CloudFront → Distributions
2. Status : "Deploying" → "Enabled" (5-15 minutes)
```

## ✅ Tester

```
1. CloudFront → Distributions → Votre distribution
2. Copiez le "Distribution domain name"
   Ex: d1234abcd.cloudfront.net
3. Ouvrez : https://d1234abcd.cloudfront.net
4. ✓ Votre site s'affiche en HTTPS !
```

## 🔄 Invalider le cache (après modifications)

### Dashboard

```
1. CloudFront → Distributions → Votre distribution
2. Onglet "Invalidations" → Create invalidation
3. Object paths : /*
4. Create invalidation ✓
5. Attendez "Completed" (2-5 minutes)
```

### CLI

```bash
# Créer une invalidation
aws cloudfront create-invalidation \
  --distribution-id EXXXXXXXXXXXXX \
  --paths "/*"
```

---

# 🔧 Troubleshooting

## ❌ 403 Forbidden sur S3

```
1. Vérifiez la Bucket Policy
2. Vérifiez que "Block all public access" est OFF
3. Vérifiez le nom du bucket dans la policy
```

## ❌ AccessDenied sur CloudFront

```
1. Attendez que le status soit "Enabled"
2. Vérifiez que la Bucket Policy inclut CloudFront
3. Créez une invalidation
```

## ❌ Le site ne s'affiche pas

```
1. Vérifiez "Default root object" = index.html
2. Vérifiez que index.html est à la racine du bucket
3. Videz le cache du navigateur (Ctrl+Shift+Delete)
```

---

# 🧹 Nettoyage

```bash
# 1. Désactiver la distribution CloudFront
aws cloudfront update-distribution \
  --id EXXXXXXXXXXXXX \
  --if-match ETAG \
  --distribution-config '..., "Enabled": false, ...'

# 2. Attendre que le status soit "Deployed"

# 3. Supprimer la distribution
aws cloudfront delete-distribution \
  --id EXXXXXXXXXXXXX \
  --if-match ETAG

# 4. Vider le bucket S3
aws s3 rm s3://mon-site-2024-tom --recursive

# 5. Supprimer le bucket
aws s3 rb s3://mon-site-2024-tom
```

---

## 📊 Comparaison S3 vs CloudFront

| Aspect | S3 Direct | CloudFront |
|--------|-----------|------------|
| **Vitesse** | Bonne | **Très rapide** |
| **Cache** | Non | **Oui (200+ serveurs)** |
| **HTTPS** | Payant | **Gratuit** |
| **Coût** | Moins cher | Plus cher (mais plus rapide) |
| **Latence** | Variable | **Faible (edge locations)** |

---

## ✅ Checklist Finale

- [ ] Bucket S3 créé
- [ ] Fichiers uploadés (index.html, styles.css, error.html)
- [ ] Bucket Policy configurée
- [ ] Static Website Hosting activé
- [ ] Test S3 direct OK
- [ ] Distribution CloudFront créée
- [ ] Status = Enabled
- [ ] Test CloudFront OK (HTTPS)

---

[⬅️ Retour : Job1](./Job1_EC2_AutoScaling_ALB.md) | [➡️ Suite : Job3_RDS.md](./Job3_RDS.md)
