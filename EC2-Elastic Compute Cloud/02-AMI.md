# AMI - Amazon Machine Image 📸

Snapshot complet d'une instance EC2 = OS + apps + config + données.

---

## 🎯 À quoi ça sert ?

- Sauvegarder une instance configurée
- Créer 100 instances identiques à partir d'une seule
- Backup avant changements importants
- Versionner votre serveur (v1, v2, v3...)

---

## 📊 Comparaison

| | AMI | Snapshot EBS | Launch Template |
|---|---|---|---|
| **Sauvegarde** | Complète (OS + apps) | Juste disque | Config + script |
| **Taille** | Grosse (~2-5 GB) | Moyenne | Petit |
| **Temps création** | 5-10 min | 2-5 min | Immédiat |
| **Réutilisation** | Créer instances | Attacher disque | Créer instances |
| **Cas d'usage** | Production | Backup | Auto Scaling |

---

## 🖼️ DASHBOARD AWS

### Créer une AMI

```
1. EC2 > Instances > Sélectionnez instance
2. Clic droit > Image and templates > Create image
3. Name: debian-nginx-v1
4. Description: Debian with Nginx PHP installed
5. Create image ✓
6. Attendre 5-10 min
```

### Voir vos AMIs

```
EC2 > AMIs > Owned by me
- État : Available
- Root volume size : disque
- Architecture : x86_64
```

### Créer instance depuis AMI

```
EC2 > AMIs > Sélectionnez votre AMI
Clic droit > Launch instance from image
- Instance type : t2.micro
- Key pair : aws_arch
- Launch ✓
```

### Supprimer une AMI

```
EC2 > AMIs > Sélectionnez
Clic droit > Deregister image
✓ Fait
```

---

## 💻 CLI

### Créer une AMI

```bash
aws ec2 create-image \
  --instance-id i-0123456789abcdef0 \
  --name debian-nginx-v1 \
  --description "Debian with Nginx PHP"
```

### Lister vos AMIs

```bash
aws ec2 describe-images --owners self
```

### Lancer instance depuis AMI

```bash
aws ec2 run-instances \
  --image-id ami-0a1b2c3d4e5f6g7h8 \
  --instance-type t2.micro \
  --key-name aws_arch
```

### Supprimer une AMI

```bash
aws ec2 deregister-image --image-id ami-0a1b2c3d4e5f6g7h8
```

---

## 💡 BONNES PRATIQUES

- **Nommer clairement** : `debian-nginx-v1-2024-12-18`
- **Tagger** : Environment (prod/test), Owner, Version
- **Nettoyer** : Supprimer les vieilles AMIs (coûtent cher)
- **Tester** : Toujours lancer une instance depuis l'AMI avant de la garder

---

[⬅️ Retour](./README.md)
