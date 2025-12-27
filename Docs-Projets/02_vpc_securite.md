# 🔒 02. VPC et Security Groups

> **Objectif** : Créer le réseau virtuel et configurer les règles de sécurité.  
> **Durée** : 1 heure  
> **Niveau** : ⭐⭐ Intermédiaire

---

## 🎯 Ce que tu vas créer

Dans cette étape, nous allons :
- ✅ Créer un VPC (réseau virtuel)
- ✅ Configurer 2 subnets publics (multi-AZ)
- ✅ Ajouter une Internet Gateway
- ✅ Configurer les tables de routage
- ✅ Créer les Security Groups

---

## 🌐 Étape 1 : Créer le VPC

### 1.1. Accéder au service VPC

1. Connecte-toi à la [console AWS](https://console.aws.amazon.com/)
2. Vérifie que tu es bien sur la région **Europe (Paris) eu-west-3**
3. Dans la barre de recherche, tape **"VPC"**
4. Clique sur **"VPC"**

### 1.2. Lancer la création

1. Dans le menu de gauche, clique sur **"Your VPCs"**
2. Clique sur le bouton **"Create VPC"**
3. Sélectionne **"VPC and more"** (création assistée)

### 1.3. Configuration du VPC

Remplis les champs suivants :

```yaml
Name tag auto-generation: webapp-prod
IPv4 CIDR block: 10.0.0.0/16
IPv6 CIDR block: No IPv6 CIDR block
Tenancy: Default

Number of Availability Zones: 2
Number of public subnets: 2
Number of private subnets: 0

NAT gateways: None
VPC endpoints: None
DNS hostnames: Enable
DNS resolution: Enable
```

### 1.4. Vérification des subnets

Tu devrais voir :

```
Public subnet 1: 10.0.0.0/20   (AZ: eu-west-3a)
Public subnet 2: 10.0.16.0/20  (AZ: eu-west-3b)
```

✅ **Modifie les CIDR pour plus de simplicité :**

```
Public subnet 1: 10.0.1.0/24   (AZ: eu-west-3a)
Public subnet 2: 10.0.2.0/24   (AZ: eu-west-3b)
```

### 1.5. Créer le VPC

1. Clique sur **"Create VPC"**
2. ⏱️ Attends 2-3 minutes
3. ✅ Message de confirmation : "Successfully created VPC"

---

## 🔍 Étape 2 : Vérifier les composants créés

### 2.1. VPC

1. Menu gauche → **"Your VPCs"**
2. Trouve ton VPC : `webapp-prod-vpc`
3. Vérifie :
   - ✅ IPv4 CIDR : `10.0.0.0/16`
   - ✅ DNS resolution : enabled
   - ✅ DNS hostnames : enabled

### 2.2. Subnets

1. Menu gauche → **"Subnets"**
2. Tu dois avoir **2 subnets publics** :

| Nom | CIDR | AZ | Type |
|-----|------|-----|------|
| webapp-prod-subnet-public1-eu-west-3a | 10.0.1.0/24 | eu-west-3a | Public |
| webapp-prod-subnet-public2-eu-west-3b | 10.0.2.0/24 | eu-west-3b | Public |

### 2.3. Internet Gateway

1. Menu gauche → **"Internet Gateways"**
2. Vérifie que l'IGW est **attaché** au VPC
3. État : `Attached` ✅

### 2.4. Route Tables

1. Menu gauche → **"Route Tables"**
2. Sélectionne la route table des subnets publics
3. Onglet **"Routes"** → vérifie :

```
Destination        Target
10.0.0.0/16       local (trafic interne au VPC)
0.0.0.0/0         igw-xxxxx (tout le reste → Internet)
```

✅ Si tu vois ces 2 routes, c'est parfait !

---

## 🛡️ Étape 3 : Créer les Security Groups

### 3.1. Security Group pour le Load Balancer

**But** : Autoriser le trafic HTTP/HTTPS depuis Internet

1. Menu gauche → **"Security Groups"**
2. Clique sur **"Create security group"**

**Configuration :**

```yaml
Security group name: webapp-prod-sg-alb
Description: Security group for Application Load Balancer
VPC: webapp-prod-vpc
```

**Inbound rules :**

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| HTTP | TCP | 80 | 0.0.0.0/0 | Allow HTTP from Internet |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Allow HTTPS from Internet |

**Outbound rules :**

```
Laisser la règle par défaut :
Type: All traffic
Destination: 0.0.0.0/0
```

3. Clique sur **"Create security group"**

---

### 3.2. Security Group pour les instances EC2

**But** : Autoriser le trafic uniquement depuis le Load Balancer + SSH pour l'admin

1. Clique sur **"Create security group"**

**Configuration :**

```yaml
Security group name: webapp-prod-sg-web
Description: Security group for web servers
VPC: webapp-prod-vpc
```

**Inbound rules :**

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| HTTP | TCP | 80 | webapp-prod-sg-alb | Allow HTTP from ALB only |
| SSH | TCP | 22 | Mon IP | Allow SSH from my IP |

⚠️ **Important pour la règle HTTP** :
- Dans la colonne "Source", ne tape **PAS** `webapp-prod-sg-alb`
- Clique dans le champ et **sélectionne le Security Group** dans la liste
- AWS va automatiquement mettre : `sg-xxxxxxxxx`

⚠️ **Pour la règle SSH** :
- Clique sur **"My IP"** dans le menu déroulant
- AWS détecte automatiquement ton adresse IP publique

**Outbound rules :**

```
Laisser la règle par défaut :
Type: All traffic
Destination: 0.0.0.0/0
```

3. Clique sur **"Create security group"**

---

## 📋 Récapitulatif des Security Groups

### SG du Load Balancer (webapp-prod-sg-alb)

```
┌─────────────────────────────────────┐
│     webapp-prod-sg-alb              │
├─────────────────────────────────────┤
│ INBOUND:                            │
│  → HTTP (80)   from 0.0.0.0/0       │
│  → HTTPS (443) from 0.0.0.0/0       │
│                                     │
│ OUTBOUND:                           │
│  → ALL         to   0.0.0.0/0       │
└─────────────────────────────────────┘
```

### SG des instances Web (webapp-prod-sg-web)

```
┌─────────────────────────────────────┐
│     webapp-prod-sg-web              │
├─────────────────────────────────────┤
│ INBOUND:                            │
│  → HTTP (80)   from sg-alb          │
│  → SSH (22)    from Mon IP          │
│                                     │
│ OUTBOUND:                           │
│  → ALL         to   0.0.0.0/0       │
└─────────────────────────────────────┘
```

---

## 🧪 Étape 4 : Tests de validation

### 4.1. Vérifier le VPC

```bash
# Si tu as AWS CLI installé :
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=webapp-prod-vpc"
```

**Ou via la console :**
1. VPC → Your VPCs
2. Sélectionne `webapp-prod-vpc`
3. Vérifie que le State = `available`

### 4.2. Vérifier les Subnets

1. VPC → Subnets
2. Filtre par VPC : `webapp-prod-vpc`
3. Tu dois voir **2 subnets publics**
4. Clique sur chaque subnet → onglet **"Route table"**
5. Vérifie qu'il y a une route vers `0.0.0.0/0` via l'IGW

### 4.3. Vérifier les Security Groups

1. VPC → Security Groups
2. Filtre par VPC : `webapp-prod-vpc`
3. Tu dois voir :
   - `webapp-prod-sg-alb` (Load Balancer)
   - `webapp-prod-sg-web` (EC2 instances)
   - `default` (ne pas toucher)

---

## 📊 Architecture réseau complète

Voici ce que tu as créé :

```
                    INTERNET
                       |
                       v
              [Internet Gateway]
             (igw-xxxxxxxxxx)
                       |
        ┌──────────────┴──────────────┐
        │         VPC                 │
        │      10.0.0.0/16            │
        │  (webapp-prod-vpc)          │
        └──────────────┬──────────────┘
                       |
        ┌──────────────┴──────────────┐
        |                             |
        v                             v
[Subnet Public A]           [Subnet Public B]
10.0.1.0/24                 10.0.2.0/24
eu-west-3a                  eu-west-3b
        |                             |
        └──────────────┬──────────────┘
                       |
            [Security Groups]
                 |     |
        webapp-prod-sg-alb
        webapp-prod-sg-web
```

---

## ✅ Checklist de validation

Avant de passer à l'étape suivante, vérifie :

- [ ] VPC créé avec CIDR 10.0.0.0/16
- [ ] 2 subnets publics dans 2 AZ différentes
- [ ] Internet Gateway attaché au VPC
- [ ] Route table configurée avec route vers IGW
- [ ] Security Group ALB créé (ports 80 et 443 ouverts)
- [ ] Security Group Web créé (port 80 depuis ALB, port 22 depuis mon IP)
- [ ] DNS resolution et hostnames activés sur le VPC

---

## 🎨 Tags recommandés

Pour chaque ressource, ajoute ces tags :

```json
{
  "Name": "[Nom de la ressource]",
  "Project": "webapp-aws",
  "Environment": "production",
  "ManagedBy": "manual",
  "Owner": "[Ton nom]"
}
```

**Comment ajouter des tags :**
1. Sélectionne la ressource (VPC, Subnet, etc.)
2. Onglet **"Tags"**
3. Clique sur **"Manage tags"**
4. Ajoute les tags
5. **Save**

---

## 🔧 Commandes utiles

### Lister les VPCs

```bash
aws ec2 describe-vpcs --region eu-west-3
```

### Lister les Subnets

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxx"
```

### Lister les Security Groups

```bash
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-xxxxx"
```

---

## 🆘 Troubleshooting

### Problème : "No Internet Gateway attached"

**Symptôme** : Pas d'accès Internet depuis les instances

**Solution** :
1. VPC → Internet Gateways
2. Sélectionne l'IGW
3. Actions → Attach to VPC
4. Choisis `webapp-prod-vpc`

---

### Problème : "Route to Internet missing"

**Symptôme** : Subnet public mais pas d'accès Internet

**Solution** :
1. VPC → Route Tables
2. Sélectionne la route table du subnet
3. Onglet Routes → Edit routes
4. Add route : `0.0.0.0/0` → Target : `igw-xxxxx`
5. Save

---

### Problème : "Cannot connect to instance via SSH"

**Causes possibles** :
1. ❌ Security Group n'autorise pas ton IP
2. ❌ Instance dans un subnet privé
3. ❌ Pas de route vers IGW

**Solutions** :
1. Vérifie le Security Group (port 22 autorisé pour ton IP)
2. Vérifie que l'instance est dans un subnet public
3. Vérifie la route table du subnet

---

## 📚 Pour aller plus loin

### Concepts avancés (hors scope du projet)

- **NAT Gateway** : pour les subnets privés
- **VPC Peering** : connecter 2 VPCs
- **VPC Endpoints** : accès privé aux services AWS
- **Network ACLs** : firewall au niveau subnet
- **Flow Logs** : logs du trafic réseau

### Documentation officielle

- [AWS VPC Guide](https://docs.aws.amazon.com/vpc/)
- [Security Groups Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)

---

## 🎯 Récapitulatif

Tu as maintenant :
- ✅ Un VPC isolé et sécurisé
- ✅ 2 subnets publics multi-AZ
- ✅ Une Internet Gateway configurée
- ✅ Des Security Groups pour sécuriser le trafic

---

## 🚀 Prochaine étape

**Direction [03_instance_ec2.md](03_creation_instance_ec2.md)** pour créer ta première instance EC2 !

---
