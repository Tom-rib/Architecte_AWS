# Server Logging - Logs des Requêtes 📝

Enregistrer tous les accès à votre bucket S3.

---

## 🎯 À quoi ça sert ?

- Audit trail (qui accède à quoi)
- Dépannage (erreurs, patterns)
- Sécurité (détecter accès suspects)
- Compliance

---

## 📊 Comparaison

| | Server Logging | CloudTrail | CloudWatch |
|---|---|---|---|
| **Quoi** | Accès S3 | Appels API AWS | Métriques |
| **Détail** | Très détaillé | Résumé | Général |
| **Coût** | 0.04€ par 1k logs | Gratuit (1 trail) | Payant |
| **Cas** | Audit S3 | Compliance API | Dashboard |

---

## 🖼️ DASHBOARD AWS

### Activer Server Logging

```
1. Bucket source > Properties > Server access logging
2. Edit > Enable
3. Target bucket : sélectionnez (ou créez nouveau)
   ⚠️ Bucket cible doit être dans même région
4. Target prefix : logs/ (optionnel, pour organiser)
5. Save changes ✓
```

### Voir les logs

```
1. Bucket cible > logs/ (voir objets)
2. Chaque log = 1 fichier avec accès horodaté
3. Format : 
   bucket-name 127.0.0.1 - [date] "GET /index.html" 200 1024
```

---

## 💻 CLI

### Activer Server Logging

```bash
aws s3api put-bucket-logging \
  --bucket mon-bucket \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "mon-bucket-logs",
      "TargetPrefix": "logs/"
    }
  }'
```

### Voir Server Logging

```bash
aws s3api get-bucket-logging --bucket mon-bucket
```

### Désactiver Server Logging

```bash
aws s3api put-bucket-logging \
  --bucket mon-bucket \
  --bucket-logging-status '{}'
```

---

## 📌 NOTES

- **Bucket cible** : peut être même bucket (pas recommandé)
- **Logs latence** : quelques heures de délai
- **Coût** : 0.04€ per 1000 log objects (négligeable)
- **Analyse** : utiliser Athena pour requêtes sur logs

---

[⬅️ Retour](./README.md)
