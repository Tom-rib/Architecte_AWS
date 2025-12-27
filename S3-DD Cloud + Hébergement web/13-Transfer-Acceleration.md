# Transfer Acceleration - Upload Rapide 🚀

Utiliser CloudFront pour accélérer uploads.

---

## 🎯 À quoi ça sert ?

- Upload plus rapide (particulièrement loin d'AWS)
- Multi-part uploads optimisés
- Worldwide transfer points
- Edge locations pour accélération

---

## 📊 Comparaison

| | S3 Direct | Transfer Acceleration |
|---|---|---|
| **Vitesse** | Variable | 2-3x plus rapide |
| **Coût** | Normal | +0.04€/GB |
| **Cas** | Normal | Upload volumineux lointain |
| **Activation** | Auto | 1 clic |

---

## 🖼️ DASHBOARD AWS

### Activer Transfer Acceleration

```
1. Bucket > Properties > Transfer acceleration
2. Edit > Enable
3. Save ✓
4. URL spéciale fournie :
   bucket.s3-accelerate.amazonaws.com
```

### Utiliser pour Upload

```
AWS CLI : aws s3 cp mon-fichier.txt s3://bucket.s3-accelerate.amazonaws.com/
```

---

## 💻 CLI

### Activer Transfer Acceleration

```bash
aws s3api put-bucket-accelerate-configuration \
  --bucket mon-bucket \
  --accelerate-configuration Status=Enabled
```

### Vérifier statut

```bash
aws s3api get-bucket-accelerate-configuration --bucket mon-bucket
```

### Upload avec accélération

```bash
aws s3 cp mon-gros-fichier.zip s3://bucket/ \
  --region eu-west-3 \
  --use-accelerate-endpoint
```

---

## 📌 NOTES

- **Coût** : +0.04€/GB transferred (additionnel)
- **Non-garantit** : plus rapide dans plupart des cas
- **Dual-stack** : supporte IPv4 et IPv6
- **Edge locations** : AWS accélère automatiquement

---

[⬅️ Retour](./README.md)
