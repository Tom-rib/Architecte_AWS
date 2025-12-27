# Buckets - Créer et Gérer 🏪

Bucket = conteneur principal pour tous vos fichiers S3.

---

## 🎯 À quoi ça sert ?

- Conteneur pour organiser les fichiers
- Isoler données par projet/env
- Appliquer permissions au niveau bucket
- Activer fonctionnalités (versioning, lifecycle, etc)

---

## 🖼️ DASHBOARD AWS

### Créer un Bucket

```
1. S3 > Buckets > Create bucket
2. Bucket name : mon-bucket-2024
   ⚠️ DOIT être unique au monde
   Exemple : tom-aws-bucket-20241226
3. Region : eu-west-3 (Paris)
4. Object Ownership : ACLs disabled (recommandé)
5. Block Public Access :
   ☑ Cochez tout (PRIVÉ par défaut)
6. Encryption : Enable (recommandé)
   Server-side encryption : AES-256
7. Versioning : Disable (optionnel)
8. Create bucket ✓
```

### Voir les buckets

```
1. S3 > Buckets
- Nom du bucket
- Région
- Date création
- Taille
- Nombre objets
```

### Propriétés du bucket

```
1. Buckets > Sélectionnez bucket
2. Onglet "Properties"
- Static website hosting (si activé)
- Versioning status
- Encryption
- Logging
```

### Supprimer un Bucket

```
1. Buckets > Sélectionnez
2. Delete
⚠️ Bucket DOIT être vide avant suppression
```

---

## 💻 CLI

### Créer un Bucket

```bash
aws s3api create-bucket \
  --bucket mon-bucket-2024 \
  --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3
```

### Lister les Buckets

```bash
aws s3 ls
# ou
aws s3api list-buckets
```

### Récupérer infos du Bucket

```bash
aws s3api head-bucket --bucket mon-bucket-2024
```

### Supprimer un Bucket (vide)

```bash
aws s3 rb s3://mon-bucket-2024
```

### Supprimer un Bucket (avec fichiers)

```bash
# ⚠️ Attention : supprime TOUT
aws s3 rm s3://mon-bucket-2024 --recursive
aws s3 rb s3://mon-bucket-2024
```

---

## 🏷️ Tags (optionnel)

Ajouter des tags au bucket pour organisation/coûts :

```bash
aws s3api put-bucket-tagging \
  --bucket mon-bucket-2024 \
  --tagging 'TagSet=[{Key=Environment,Value=test},{Key=Owner,Value=tom}]'
```

---

## 📌 NOTES

- **Nom unique** : erreur si nom déjà utilisé
- **Région** : une fois créé, ne change pas
- **Coût** : storage + requests + data transfer
- **Suppression** : impossible si bucket non vide
- **Versionning** : à activer AVANT les uploads (ne rétroagit pas)

---

[⬅️ Retour](./README.md)
