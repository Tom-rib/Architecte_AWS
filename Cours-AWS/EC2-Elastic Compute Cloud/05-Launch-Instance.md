# Créer une Instance EC2 🚀

Lancer votre première machine virtuelle.

---

## 🎯 À quoi ça sert ?

C'est votre serveur Linux/Windows à configurer et gérer.

---

## 🖼️ DASHBOARD AWS

### Lancer une Instance

```
1. EC2 > Instances > Launch instance
```

### Étape 1 : AMI (système d'exploitation)

```
- Sélectionnez : Debian 12
  (ou Ubuntu 24.04 LTS)
- Recommandé : Debian (léger, gratuit)
```

### Étape 2 : Instance type

```
- Type : t2.micro
- vCPU : 1
- Memory : 1 GB
- ✅ GRATUIT avec AWS free tier
```

### Étape 3 : Key pair (authentification SSH)

```
- Sélectionnez : aws_arch (ou créez nouveau)
- Format : PEM (pour Linux/Mac) ou PPK (pour Putty)
- Téléchargez si nouveau
- ✓ Gardez précieusement !
```

### Étape 4 : Network

```
- VPC : default
- Subnet : any (auto)
- Auto-assign public IP : Enable
- (vous aurez une IP publique)
```

### Étape 5 : Security group

```
Créez nouveau :
- Name : sg-ec2-default
- Description : SSH, HTTP, HTTPS

Ajouter rules :
├─ SSH (22) : Votre IP (restrictif !)
├─ HTTP (80) : 0.0.0.0/0 (public)
└─ HTTPS (443) : 0.0.0.0/0 (public)
```

### Étape 6 : Storage (disque)

```
- Size : 20 GB
- Type : gp3 (par défaut)
- Encryption : Enable (recommandé)
- Delete on termination : checked
```

### Étape 7 : Advanced

```
- IAM instance profile : (optionnel)
- User data : (laissez vide pour l'instant)
- Monitoring : disabled (pour test)
- Metadata options : default
```

### Étape 8 : Tags

```
Ajouter :
- Key: Name | Value: debian-instance-1
- Key: Environment | Value: test
- Key: Owner | Value: tom
```

### Lancer

```
- Cliquez : Launch instance ✓
- Attendre 30 secondes
- Instance apparaît en "Running"
```

### Récupérer les infos

```
1. Instances > Sélectionnez votre instance
2. Notez :
   - Instance ID : i-0123456789abcdef0
   - Public IPv4 : 54.123.45.67
   - Private IPv4 : 10.0.1.5
```

---

## 💻 CLI

### Créer une Instance

```bash
aws ec2 run-instances \
  --image-id ami-0a1b2c3d4e5f6g7h8 \
  --instance-type t2.micro \
  --key-name aws_arch \
  --security-group-ids sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=debian-instance-1}]' \
  --region eu-west-3
```

### Lister les Instances

```bash
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --region eu-west-3
```

### Récupérer IP d'une Instance

```bash
aws ec2 describe-instances \
  --instance-ids i-0123456789abcdef0 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text
```

### Arrêter une Instance

```bash
aws ec2 stop-instances --instance-ids i-0123456789abcdef0
```

### Démarrer une Instance

```bash
aws ec2 start-instances --instance-ids i-0123456789abcdef0
```

### Redémarrer une Instance

```bash
aws ec2 reboot-instances --instance-ids i-0123456789abcdef0
```

### Supprimer une Instance

```bash
aws ec2 terminate-instances --instance-ids i-0123456789abcdef0
```

---

## 📌 NOTES

- **Instance ID** : identifiant unique (commencez par `i-`)
- **Public IP** : change si vous arrêtez l'instance (utilisez Elastic IP pour fixer)
- **Security Group** : c'est votre firewall, restrictif par défaut
- **Coût** : t2.micro gratuit 750h/mois, puis ~5-15€/mois

---

[⬅️ Retour](./README.md)
