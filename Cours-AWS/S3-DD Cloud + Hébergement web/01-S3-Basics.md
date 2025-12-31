# S3 - Basics 🪣

Simple Storage Service (S3) = stockage illimité de fichiers dans le cloud AWS.

---

## 🎯 À quoi ça sert ?

- Stocker des fichiers (documents, images, vidéos)
- Sauvegarder des données
- Héberger des sites web statiques
- Archiver à long terme
- Partager des fichiers

---

## 📊 Comparaison : Disque local vs S3

| | Disque local | S3 |
|---|---|---|
| **Capacité** | Limitée | Illimitée |
| **Coût** | Fixe (hardware) | Pay-as-you-go |
| **Accès** | Local | De partout (Web) |
| **Durabilité** | 1 disque = risque | 11x 9s (99.999999999%) |
| **Sauvegardes** | Manuel | Automatique |
| **Partage** | USB/Email | Lien public |
| **Contrôle d'accès** | Utilisateurs OS | IAM policies fine-grained |

---

## 🗂️ Hiérarchie S3

```
Bucket (mon-bucket)
├── Document (images/)
│   ├── photo1.jpg
│   ├── photo2.jpg
│   └── photo3.jpg
├── Document (videos/)
│   ├── video1.mp4
│   └── video2.mp4
└── Document (index.html)
```

**Important :** S3 n'a pas vraiment de "dossiers", juste des clés avec "/" (pseudo-dossiers)

---

## 💾 Stockage vs Accès

| Opération | Coût |
|-----------|------|
| **Upload** | GRATUIT |
| **Stockage** | 0.023€ / GB / mois |
| **Download (OUT)** | 0.085€ / GB |
| **Download (IN)** | GRATUIT |
| **Requête** | 0.0004€ / 10k requêtes |

**Exemple :** 100 GB stockés + 10 GB téléchargés/mois = ~2.5€/mois

---

## 🔐 Sécurité par défaut

```
S3 Bucket = PRIVÉ par défaut
├─ Vous = accès total (propriétaire)
├─ Autres AWS users = RIEN (bloqués)
└─ Public Internet = RIEN (bloqués)

Pour partager → Utiliser Bucket Policy
Pour restreindre → IAM Policies
```

---

## 🖼️ DASHBOARD AWS

### Accéder à S3

```
1. AWS Console > S3
2. Voir les buckets existants
3. Créer nouveau bucket (voir 02-Buckets.md)
```

---

## 💻 CLI

### Configurer AWS CLI

```bash
aws configure
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: eu-west-3
# Default output format: json
```

### Lister les buckets

```bash
aws s3 ls
# Retour : mon-bucket, mon-autre-bucket
```

### Lister fichiers d'un bucket

```bash
aws s3 ls s3://mon-bucket/
# Retour : fichier1.txt, fichier2.jpg, images/ (dossier)
```

---

## 📌 NOTES

- **Bucket unique** : noms uniques au monde (déjà utilisés = erreur)
- **Région** : bucket dans 1 région = données proches + latence basse
- **Versioning** : garder historique des fichiers (optionnel)
- **Lifecycle** : supprimer/archiver automatiquement (optionnel)
- **Encryption** : chiffrer au repos (optionnel, recommandé)
- **CloudFront** : toujours utiliser pour distribuer globalement

---

[⬅️ Retour](./README.md)
