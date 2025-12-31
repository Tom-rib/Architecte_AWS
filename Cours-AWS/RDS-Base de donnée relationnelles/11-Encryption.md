# Encryption - Chiffrement 🔐

Chiffrer données BD au repos et en transit.

---

## 🎯 À quoi ça sert ?

- Sécurité données
- Compliance réglementaire
- Protection disque

---

## 📊 Types chiffrement

| | At rest | In transit |
|---|---|---|
| **Quoi** | Données disque | Données réseau |
| **Coût** | Gratuit | Gratuit |
| **Activation** | À la création | Par défaut SSL |

---

## 🖼️ DASHBOARD AWS

### Activer chiffrement (création)

```
1. RDS > Create database
2. Encryption section
3. ☑ Enable encryption
4. KMS key : aws/rds (par défaut)
5. Create ✓

⚠️ IMPOSSIBLE à ajouter après création
```

### Voir certificat SSL

```
RDS > Databases > my-database
- CA certificate : rds-ca-2019, etc
```

---

## 💻 CLI

### Créer instance chiffrée

```bash
aws rds create-db-instance \
  --db-instance-identifier my-database \
  --storage-encrypted \
  --kms-key-id arn:aws:kms:eu-west-3:123456789:key/12345678
```

---

## 📌 NOTES

- **At rest** : AWS gère (KMS)
- **In transit** : SSL automatique
- **Coût** : gratuit (sauf KMS custom)
- **Performance** : impact négligeable

---

[⬅️ Retour](./README.md)
