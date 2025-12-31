# EC2 Masterclass 🚀

Mémo rapide pour déployer et gérer des instances EC2 avec Auto Scaling et Load Balancer.

**Format :** Dashboard AWS (clics) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts de base
- **[EC2 Basics](./01-EC2-Basics.md)** - Qu'est-ce que EC2 ?
- **[AMI](./02-AMI.md)** - Sauvegarder une config d'instance
- **[EBS Snapshots](./03-EBS-Snapshots.md)** - Sauvegarder les disques
- **[Elastic IP](./04-Elastic-IP.md)** - IP fixe (ne change jamais)

### Déploiement
- **[Créer une Instance](./05-Launch-Instance.md)** - Lancer une EC2
- **[SSH - Connexion](./06-SSH-Connection.md)** - Se connecter à l'instance
- **[Installer l'App](./07-Install-App.md)** - Nginx + PHP + Page

### Scaling et Distribution
- **[Launch Template](./08-Launch-Template.md)** - Modèle pour ASG
- **[Auto Scaling](./09-Auto-Scaling.md)** - Créer/détruire instances auto
- **[Load Balancer](./10-Load-Balancer.md)** - Répartir le trafic

### Sécurité
- **[HTTPS](./11-HTTPS.md)** - Certificat SSL auto-signé
- **[SNS](./12-Notification-mail-SNS.md)** - Notifications par email

### Référence
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS

---

## 🎯 FLUX RAPIDE

```
1. Créer instance EC2 (05-Launch-Instance.md)
2. SSH et installer app (06-SSH.md + 07-Install-App.md)
3. Créer Launch Template (08-Launch-Template.md)
4. Créer Auto Scaling Group (09-Auto-Scaling.md)
5. Créer Load Balancer (10-Load-Balancer.md)
6. (Optionnel) Ajouter HTTPS (11-HTTPS.md)
7. (Optionnel) Ajouter SNS (12-SNS.md)
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Durée |
|---------|---------|-------|
| **EC2** | Serveur virtuel | - |
| **AMI** | Sauvegarder instance | 5-10 min |
| **Snapshot** | Sauvegarder disque | 2-5 min |
| **Elastic IP** | IP fixe | Immédiat |
| **Launch Template** | Modèle instance | Immédiat |
| **Auto Scaling** | Gérer instances auto | Immédiat |
| **Load Balancer** | Répartir trafic | 2-3 min |
| **HTTPS** | Certificat SSL | 5 min |

---

## 🚀 BESOIN D'AIDE RAPIDE ?

- Créer une instance ? → [05-Launch-Instance.md](./05-Launch-Instance.md)
- Se connecter ? → [06-SSH-Connection.md](./06-SSH-Connection.md)
- Scaler automatiquement ? → [09-Auto-Scaling.md](./09-Auto-Scaling.md)
- Utiliser CLI ? → [CLI-Commands.md](./CLI-Commands.md)

---

## 📌 NOTES IMPORTANTES

- **User Debian par défaut :** `admin` (pas `ubuntu`)
- **Région par défaut :** `eu-west-3` (Paris)
- **Instance type recommandée :** `t2.micro` (gratuit)
- **Toujours :** Utiliser Launch Template + Auto Scaling (vs créer instances manuellement)

---

**Créé pour mémoriser rapidement les concepts EC2** 📚
