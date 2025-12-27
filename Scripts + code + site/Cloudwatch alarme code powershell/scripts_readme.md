# CloudWatch Alarms Setup Scripts 🚨

Scripts automatisés pour créer **10 alarmes CloudWatch optimisées** en 2 minutes.

---

## 📋 À QUOI ÇA SERT ?

Ces scripts créent automatiquement :

```
✅ 1x EC2 CPU Alarm
✅ 1x Lambda Errors Alarm
✅ 1x Lambda Duration Alarm
✅ 1x RDS Connections Alarm
✅ 1x API 5XX Errors Alarm
✅ 1x API Latency Alarm
✅ 1x DynamoDB Read Throttles Alarm
✅ 1x DynamoDB Write Throttles Alarm
✅ 1x EC2 Network In Alarm
✅ 1x Composite Alarm (EC2 OR Lambda)
```

Tous les 10 envoient une notification SNS par email quand déclenchées.

**Coût** : 0€ (free tier AWS)

---

## 🚀 DÉMARRER RAPIDEMENT

### Prérequis

```
- AWS CLI installé (aws --version)
- AWS credentials configurés (aws configure)
- SNS Topic créé dans AWS (ex: alerts-production)
- Email confirmé dans SNS
```

### Pour Windows (PowerShell)

```powershell
# 1. Modifier le script avec VOS valeurs
# Ouvrir setup-alarms.ps1
# Chercher "YOUR_AWS_ACCOUNT_ID_HERE"
# Remplacer par votre AWS Account ID (ex: 703216717306)

# 2. Exécuter
.\setup-alarms.ps1

# 3. Voir les résultats
# CloudWatch > Alarms > All Alarms
```

### Pour Linux/Mac (Bash)

```bash
# 1. Modifier le script
# nano setup-alarms.sh
# Chercher "YOUR_AWS_ACCOUNT_ID_HERE"
# Remplacer par votre AWS Account ID

# 2. Rendre exécutable
chmod +x setup-alarms.sh

# 3. Exécuter
./setup-alarms.sh

# 4. Voir les résultats
# CloudWatch > Alarms > All Alarms
```

---

## 🔧 CONFIGURATION

### Étape 1 : Trouver ton AWS Account ID

**Dans AWS Console** :

```
1. Profil (en haut à droite)
2. Security credentials
3. Copier ton Account ID (12 chiffres)
   Exemple: 703216717306
```

**Ou via CLI** :

```bash
aws sts get-caller-identity
# Chercher "Account" (12 chiffres)
```

### Étape 2 : Créer SNS Topic (si n'existe pas)

**Via AWS Console** :

```
1. SNS > Topics > Create Topic
2. Name: alerts-production
3. Type: Standard
4. Create Topic
```

**Via CLI** :

```bash
aws sns create-topic --name alerts-production --region eu-west-3
```

### Étape 3 : S'abonner par Email

**Via AWS Console** :

```
1. Sélectionner topic: alerts-production
2. Create Subscription
3. Protocol: Email
4. Endpoint: your-email@example.com
5. Create Subscription
6. Vérifier email et cliquer lien de confirmation
```

**Via CLI** :

```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:eu-west-3:YOUR_AWS_ACCOUNT_ID:alerts-production \
  --protocol email \
  --notification-endpoint your-email@example.com \
  --region eu-west-3
```

---

## 📝 MODIFIER LE SCRIPT

### Variables à changer

```powershell
# PowerShell (setup-alarms.ps1)
$AWS_ACCOUNT_ID = "YOUR_AWS_ACCOUNT_ID_HERE"  # ← REMPLACER
$SNS_TOPIC_NAME = "alerts-production"         # (ou ton topic name)
$REGION = "eu-west-3"                         # (ou ta région)
```

```bash
# Bash (setup-alarms.sh)
AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID_HERE"     # ← REMPLACER
SNS_TOPIC_NAME="alerts-production"            # (ou ton topic name)
REGION="eu-west-3"                            # (ou ta région)
```

---

## ✅ VÉRIFIER QUE ÇA MARCHE

### Voir les alarmes créées

**Via AWS Console** :

```
CloudWatch > Alarms > All Alarms
→ Tu devrais voir 10 alarmes
```

**Via CLI** :

```bash
aws cloudwatch describe-alarms --region eu-west-3
```

### Tester une alarme

```bash
# Déclencher alarme manuellement
aws cloudwatch set-alarm-state \
  --alarm-name ec2-cpu-high-sim \
  --state-value ALARM \
  --state-reason "Test manual"

# Tu devrais recevoir un email SNS!
```

---

## 📊 SEUILS (SIMULATION)

Les seuils sont **TRÈS BAS** pour tester facilement :

| Alarme | Seuil | Normal | Raison |
|---|---|---|---|
| EC2 CPU | 5% | 80% | Facile à atteindre |
| Lambda Errors | > 0 | > 5 | Teste toute erreur |
| Lambda Duration | > 100ms | > 5000ms | Teste latency |
| RDS Connections | > 1 | > 100 | Teste connexion |
| API 5XX Errors | > 0 | > 5% | Teste toute erreur |
| API Latency | > 100ms | > 1000ms | Teste latency |
| DynamoDB Throttles | > 0 | > 0 | CRITIQUE |

---

## 🔄 MODIFIER SEUILS

Pour production, modifie les seuils dans le script :

```powershell
# Exemple: Changer EC2 CPU de 5% à 80%
--threshold 5         # Changer à 80
```

Puis réexécute le script.

---

## 🗑️ SUPPRIMER LES ALARMES

Si tu veux les supprimer :

```bash
# Supprimer une alarme
aws cloudwatch delete-alarms --alarm-names ec2-cpu-high-sim

# Supprimer toutes les alarmes du script
aws cloudwatch delete-alarms \
  --alarm-names \
    ec2-cpu-high-sim \
    lambda-errors-sim \
    lambda-duration-sim \
    rds-connections-sim \
    api-5xx-errors-sim \
    api-latency-sim \
    dynamodb-read-throttles-sim \
    dynamodb-write-throttles-sim \
    ec2-network-in-sim \
    production-issues-sim
```

---

## 🐛 TROUBLESHOOTING

### Erreur: "Access Denied"

```
Cause: AWS credentials pas configurées
Solution: aws configure
```

### Erreur: "Topic not found"

```
Cause: SNS Topic n'existe pas
Solution: Créer le topic d'abord
```

### Erreur: "Invalid Account ID"

```
Cause: Account ID mal entré
Solution: Vérifier Account ID (12 chiffres)
```

### Alarmes pas reçues par email

```
Cause: Email pas confirmé dans SNS
Solution: Vérifier email et cliquer lien confirmation
```

---

## 📚 RESSOURCES

- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)
- [AWS SNS Documentation](https://docs.aws.amazon.com/sns/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)

---

## 📄 LICENSE

MIT License - Libre d'utilisation

---

**Créé pour Job 5: Surveillance et Alertes avec CloudWatch**