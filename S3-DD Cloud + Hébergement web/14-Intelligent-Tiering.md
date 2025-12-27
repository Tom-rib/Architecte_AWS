# Intelligent-Tiering - Archivage Automatique 🧠

Classe de storage qui bouge objets automatiquement selon accès.

---

## 🎯 À quoi ça sert ?

- Réduire coûts automatiquement
- Pas besoin de définir lifecycle rules
- Optimal pour données accès imprévisible
- Monitoring intelligent

---

## 📊 Comparaison : Classes de Storage

| | Standard | Intelligent-Tiering | Glacier |
|---|---|---|---|
| **Coût** | 0.023€/GB | 0.0125€/GB | 0.004€/GB |
| **Accès** | Instant | Instant (puis lent) | 1-5 min |
| **Cas** | Hot data | Unknown access | Archive |
| **Auto move** | Non | Oui ✓ | Non |

---

## 🖼️ DASHBOARD AWS

### Ajouter Intelligent-Tiering

```
1. Bucket > Management > Lifecycle rules
2. Create rule
3. Transitions :
   ☑ Transition to Intelligent-Tiering
   After (days) : 0 (immédiatement)
4. Create ✓
```

---

## 💻 CLI

### Upload en Intelligent-Tiering

```bash
aws s3api put-object \
  --bucket mon-bucket \
  --key mon-fichier.txt \
  --body mon-fichier.txt \
  --storage-class INTELLIGENT_TIERING
```

### Voir tiers

```bash
# Tier 1 : Frequent Access (< 30 jours)
# Tier 2 : Infrequent Access (30-90 jours)
# Tier 3 : Archive (> 90 jours, latence 1-3 heures)
# Tier 4 : Deep Archive (> 180 jours, latence 12 heures)
```

---

## 📌 NOTES

- **Monitoring** : 0.0125€/GB (inclus dans coût)
- **Automatic** : bouge sans configuration
- **Archive access** : optionnel (latence acceptable)
- **Deep archive** : optionnel (archivage long terme)

---

[⬅️ Retour](./README.md)
