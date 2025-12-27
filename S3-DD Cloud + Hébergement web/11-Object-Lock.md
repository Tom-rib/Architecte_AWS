# Object Lock - Immuabilité WORM 🔒

Write Once Read Many (WORM) = impossible de modifier/supprimer objets.

---

## 🎯 À quoi ça sert ?

- Conformité réglementaire (FINRA, FDA, etc)
- Protection anti-ransomware
- Audit trail immuable
- Données sensibles

---

## 📊 Modes

| Mode | Durée | Modification | Suppression |
|---|---|---|---|
| **Governance** | Jours/années | Avec permission | Avec permission |
| **Compliance** | Jours/années | JAMAIS | JAMAIS ✓ |
| **Legal Hold** | Indéterminé | JAMAIS | JAMAIS |

---

## 🖼️ DASHBOARD AWS

### Activer Object Lock

```
Bucket > Créer avec Object Lock activé
⚠️ IMPOSSIBLE à désactiver après création
```

### Ajouter Lock à objet

```
1. Upload fichier
2. Version > Actions > Object Lock
3. Mode : Governance ou Compliance
4. Retain until : date
5. Legal hold : optionnel
6. Save ✓
```

---

## 💻 CLI

### Uploader avec Object Lock

```bash
aws s3api put-object \
  --bucket mon-bucket \
  --key mon-fichier.txt \
  --body mon-fichier.txt \
  --object-lock-mode COMPLIANCE \
  --object-lock-retain-until-date 2025-12-31T00:00:00Z
```

### Voir Object Lock

```bash
aws s3api get-object-retention \
  --bucket mon-bucket \
  --key mon-fichier.txt
```

---

## 📌 NOTES

- **Compliance** : impossible de contourner (même AWS)
- **Governance** : root AWS account peut contourner
- **Legal Hold** : jusqu'à suppression explicite
- **Coût** : pas additionnel (versioning requis)

---

[⬅️ Retour](./README.md)
