# Access Points - Points d'Accès Simplifiés 🚪

Interfaces simplifiées pour accéder à parties spécifiques d'un bucket.

---

## 🎯 À quoi ça sert ?

- Permissions granulaires par dossier/client
- Simplifier gestion buckets énormes
- Multi-application sur même bucket
- VPC access points (privé, pas Internet)

---

## 📊 Comparaison

| | Bucket direct | Access Point | IAM Policy |
|---|---|---|---|
| **URL** | s3://bucket/ | arn:aws:s3:... | Non applicable |
| **Permissions** | Bucket entier | Specific paths | Fine-grained |
| **Accès VPC** | Non | Oui ✓ | Non |
| **Cas** | Simple | Multi-tenant | Dev/Ops |

---

## 🖼️ DASHBOARD AWS

### Créer Access Point

```
1. S3 > Access Points > Create access point
2. Name : app1-access-point
3. Bucket : sélectionnez bucket
4. Network origin : Internet (ou VPC)
5. Block Public Access : à configurer (recommandé : tout cochée)
6. Create access point ✓
7. ARN fourni : arn:aws:s3:eu-west-3:123456789:accesspoint/app1-access-point
```

### Utiliser Access Point

```
ARN : arn:aws:s3:eu-west-3:123456789:accesspoint/app1-access-point
AWS CLI : aws s3 cp fichier.txt s3://arn:aws:s3:eu-west-3:123456789:accesspoint/app1-access-point/
```

---

## 💻 CLI

### Créer Access Point

```bash
aws s3api create-access-point \
  --bucket mon-bucket \
  --name app1-access-point \
  --region eu-west-3
```

### Lister Access Points

```bash
aws s3api list-access-points --bucket mon-bucket
```

### Ajouter Policy à Access Point

```bash
aws s3api put-access-point-policy \
  --name app1-access-point \
  --policy file://policy.json
```

---

## 📌 NOTES

- **ARN** : identifiant unique du point d'accès
- **VPC Access Points** : privé, nécessite endpoints VPC
- **Permissions** : combinées avec bucket policies
- **Cas d'usage** : multi-tenant, applications séparées

---

[⬅️ Retour](./README.md)
