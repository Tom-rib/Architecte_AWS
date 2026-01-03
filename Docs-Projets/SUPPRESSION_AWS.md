# 🧹 GUIDE COMPLET DE SUPPRESSION - RESSOURCES AWS

> Comment supprimer TOUTES les ressources AWS créées  
> Version générique - Remplace les variables par tes vraies valeurs

---

## ⚠️ AVERTISSEMENT

```
ATTENTION: Les actions ci-dessous sont IRRÉVERSIBLES
Une fois supprimées, les données ne peuvent pas être récupérées

Assure-toi que tu veux vraiment tout supprimer avant de continuer!
```

---

## 📋 VARIABLES À REMPLACER

Avant de commencer, remplace ces valeurs partout:

| Variable | Exemple | Détail |
|----------|---------|--------|
| `REGION` | eu-west-3 | Ta région AWS |
| `ACCOUNT_ID` | 703216717306 | Ton AWS Account ID |
| `CLUSTER_NAME` | cluster-ecs-app | Nom du cluster ECS |
| `SERVICE_NAME` | app-service | Nom du service ECS |
| `REPOSITORY_NAME` | app-ecr | Nom du repository ECR |
| `STATE_MACHINE_NAME` | workflow-job9 | Nom de la state machine |
| `LAMBDA_FUNCTION_1` | hello-api | Nom fonction Lambda 1 |
| `LAMBDA_FUNCTION_2` | send-notification | Nom fonction Lambda 2 |
| `API_ID` | a1b2c3d4e5 | ID de l'API Gateway |
| `ASG_NAME` | scaling_job1 | Nom Auto Scaling Group |
| `LB_ARN` | arn:aws:elasticloadbalancing:... | ARN du Load Balancer |
| `LT_NAME` | debian_nginx_template | Nom du Launch Template |
| `DB_IDENTIFIER` | my-database | Identifiant RDS |
| `BUCKET_NAME` | monsitetomrib | Nom du bucket S3 |
| `SNS_TOPIC_ARN` | arn:aws:sns:region:account:topic | ARN du topic SNS |

---

# 🚀 GUIDE DÉTAILLÉ - CHAQUE SERVICE

---

# 1️⃣ ECS CLUSTER + SERVICES

## 🖥️ Dashboard

```
1. AWS Console → ECS

2. Clusters → Sélectionne CLUSTER_NAME

3. Services → Sélectionne SERVICE_NAME

4. Clique "Delete" (en haut à droite)
   → Sélectionne "Force delete"
   → Clique "Delete service"

5. Une fois supprimé
   → Reviens au cluster
   → Clique "Delete cluster"
   → Confirme
```

## 💻 CLI

```powershell
# 1. Récupère le nom exact du service
aws ecs list-services `
  --cluster CLUSTER_NAME `
  --region REGION

# 2. Arrête le service (mettre desired count à 0)
aws ecs update-service `
  --cluster CLUSTER_NAME `
  --service SERVICE_NAME `
  --desired-count 0 `
  --region REGION

# ⏳ Attends 2 minutes que les tâches s'arrêtent!

# 3. Supprime le service
aws ecs delete-service `
  --cluster CLUSTER_NAME `
  --service SERVICE_NAME `
  --force `
  --region REGION

# 4. Supprime le cluster
aws ecs delete-cluster `
  --cluster CLUSTER_NAME `
  --region REGION

# 5. Vérifie
aws ecs list-clusters --region REGION
```

---

# 2️⃣ ECR REPOSITORY

## 🖥️ Dashboard

```
1. AWS Console → ECR

2. Repositories → Sélectionne REPOSITORY_NAME

3. Clique "Delete" (en haut)
   → Tape "delete" pour confirmer
   → Clique "Delete"
```

## 💻 CLI

```powershell
# Supprime le repository (force delete les images dedans)
aws ecr delete-repository `
  --repository-name REPOSITORY_NAME `
  --force `
  --region REGION

# Vérifie
aws ecr describe-repositories --region REGION
```

---

# 3️⃣ STEP FUNCTIONS

## 🖥️ Dashboard

```
1. AWS Console → Step Functions

2. State machines → Sélectionne STATE_MACHINE_NAME

3. Clique "Delete" (en haut)
   → Confirme
```

## 💻 CLI

```powershell
# Récupère l'ARN
aws stepfunctions list-state-machines --region REGION

# Copie l'ARN complet: arn:aws:states:REGION:ACCOUNT_ID:stateMachine:STATE_MACHINE_NAME

# Supprime
aws stepfunctions delete-state-machine `
  --state-machine-arn arn:aws:states:REGION:ACCOUNT_ID:stateMachine:STATE_MACHINE_NAME `
  --region REGION

# Vérifie
aws stepfunctions list-state-machines --region REGION
```

---

# 4️⃣ LAMBDA FUNCTIONS

## 🖥️ Dashboard

```
1. AWS Console → Lambda

2. Functions → Pour chaque fonction Lambda
   (LAMBDA_FUNCTION_1, LAMBDA_FUNCTION_2, etc.)

3. Clique "Delete"
   → Tape "delete" pour confirmer
   → Clique "Delete function"
```

## 💻 CLI

```powershell
# Récupère la liste
aws lambda list-functions --region REGION

# Supprime chaque fonction
aws lambda delete-function --function-name LAMBDA_FUNCTION_1 --region REGION
aws lambda delete-function --function-name LAMBDA_FUNCTION_2 --region REGION
aws lambda delete-function --function-name LAMBDA_FUNCTION_3 --region REGION

# Vérifie
aws lambda list-functions --region REGION
```

---

# 5️⃣ API GATEWAY

## 🖥️ Dashboard

```
1. AWS Console → API Gateway

2. APIs → Sélectionne l'API

3. Clique "Delete" (en haut)
   → Confirme
```

## 💻 CLI

```powershell
# Récupère les APIs
aws apigateway get-rest-apis --region REGION

# Copie l'API ID

# Supprime
aws apigateway delete-rest-api `
  --rest-api-id API_ID `
  --region REGION

# Vérifie
aws apigateway get-rest-apis --region REGION
```

---

# 6️⃣ AUTO SCALING GROUPS

## 🖥️ Dashboard

```
1. AWS Console → EC2 → Auto Scaling Groups

2. Sélectionne ASG_NAME

3. Clique "Delete"
   → Sélectionne "Terminate instances"
   → Clique "Delete"
```

## 💻 CLI

```powershell
# Récupère la liste
aws autoscaling describe-auto-scaling-groups --region REGION

# Change min size à 0 (ASG a souvent min=1)
aws autoscaling update-auto-scaling-group `
  --auto-scaling-group-name ASG_NAME `
  --min-size 0 `
  --region REGION

# Mets desired count à 0
aws autoscaling set-desired-capacity `
  --auto-scaling-group-name ASG_NAME `
  --desired-capacity 0 `
  --region REGION

# ⏳ Attends 2 minutes

# Supprime l'ASG
aws autoscaling delete-auto-scaling-group `
  --auto-scaling-group-name ASG_NAME `
  --force-delete `
  --region REGION

# Vérifie
aws autoscaling describe-auto-scaling-groups --region REGION
```

---

# 7️⃣ LOAD BALANCERS

## 🖥️ Dashboard

```
1. AWS Console → EC2 → Load Balancers

2. Sélectionne le Load Balancer

3. Clique "Delete" (en haut)
   → Confirme
```

## 💻 CLI

```powershell
# Récupère l'ARN du Load Balancer
aws elbv2 describe-load-balancers --region REGION

# Copie l'ARN complet

# Supprime
aws elbv2 delete-load-balancer `
  --load-balancer-arn LB_ARN `
  --region REGION

# Vérifie
aws elbv2 describe-load-balancers --region REGION
```

---

# 8️⃣ LAUNCH TEMPLATES

## 🖥️ Dashboard

```
1. AWS Console → EC2 → Launch Templates

2. Sélectionne LT_NAME

3. Clique "Delete"
   → Tape "Delete"
   → Clique "Delete"
```

## 💻 CLI

```powershell
# Récupère la liste
aws ec2 describe-launch-templates --region REGION

# Supprime
aws ec2 delete-launch-template `
  --launch-template-name LT_NAME `
  --region REGION

# Vérifie
aws ec2 describe-launch-templates --region REGION
```

---

# 9️⃣ EC2 INSTANCES

## 🖥️ Dashboard

```
1. AWS Console → EC2 → Instances

2. Sélectionne toutes les instances en cours d'exécution

3. Instance State → Terminate instances
   → Confirme
```

## 💻 CLI

```powershell
# Récupère la liste des instances running
aws ec2 describe-instances `
  --region REGION `
  --query "Reservations[].Instances[?State.Name=='running'].InstanceId" `
  --output text

# Résultat: i-xxx i-yyy i-zzz

# Termine les instances
aws ec2 terminate-instances `
  --instance-ids i-xxx i-yyy i-zzz `
  --region REGION

# ⏳ Attends 2 minutes

# Vérifie
aws ec2 describe-instances `
  --region REGION `
  --query "Reservations[].Instances[].[InstanceId,State.Name]" `
  --output text
```

---

# 🔟 RDS DATABASE

## 🖥️ Dashboard

```
1. AWS Console → RDS → Databases

2. Sélectionne DB_IDENTIFIER

3. Clique "Delete" (en haut)
   → Décocher "Create final snapshot"
   → Tape "delete me"
   → Clique "Delete DB instance"

⏳ Attends 5-10 minutes (RDS prend du temps)
```

## 💻 CLI

```powershell
# Supprime l'instance RDS (sans snapshot final)
aws rds delete-db-instance `
  --db-instance-identifier DB_IDENTIFIER `
  --skip-final-snapshot `
  --region REGION

# ⏳ Attends 5-10 minutes

# Vérifie
aws rds describe-db-instances --region REGION
```

---

# 1️⃣1️⃣ S3 BUCKETS

## 🖥️ Dashboard

```
1. AWS Console → S3

2. Sélectionne BUCKET_NAME

3. Clique "Empty"
   → Tape "permanently delete"
   → Clique "Empty"

⏳ Attends que ça finisse

4. Clique "Delete"
   → Tape le nom du bucket: BUCKET_NAME
   → Clique "Delete bucket"
```

## 💻 CLI

```powershell
# 1. Vide complètement le bucket
aws s3 rm s3://BUCKET_NAME --recursive --region REGION

# ⏳ Attends que ça finisse

# 2. Supprime le bucket vide
aws s3 rb s3://BUCKET_NAME --region REGION

# Vérifie
aws s3 ls
```

---

# 1️⃣2️⃣ ATHENA DATABASE

## 🖥️ Dashboard

```
1. AWS Console → Athena → Query Editor

2. Exécute ces requêtes (une par une):

   DROP TABLE IF EXISTS DATABASE_NAME.TABLE_NAME_1;
   DROP TABLE IF EXISTS DATABASE_NAME.TABLE_NAME_2;
   DROP DATABASE IF EXISTS DATABASE_NAME;

3. Clique "Run query" pour chaque
```

## 💻 CLI

```powershell
# Supprime les tables et database
aws athena start-query-execution `
  --query-string "DROP TABLE IF EXISTS DATABASE_NAME.TABLE_NAME_1" `
  --result-configuration "OutputLocation=s3://BUCKET_NAME/QUERY_RESULTS_FOLDER/" `
  --region REGION

aws athena start-query-execution `
  --query-string "DROP TABLE IF EXISTS DATABASE_NAME.TABLE_NAME_2" `
  --result-configuration "OutputLocation=s3://BUCKET_NAME/QUERY_RESULTS_FOLDER/" `
  --region REGION

aws athena start-query-execution `
  --query-string "DROP DATABASE IF EXISTS DATABASE_NAME" `
  --result-configuration "OutputLocation=s3://BUCKET_NAME/QUERY_RESULTS_FOLDER/" `
  --region REGION

# ⏳ Attends 1 minute

# Vérifie
aws athena list-databases --region REGION
```

---

# 1️⃣3️⃣ SNS TOPICS

## 🖥️ Dashboard

```
1. AWS Console → SNS → Topics

2. Sélectionne le topic

3. Clique "Delete"
   → Tape "delete" pour confirmer
   → Clique "Delete"
```

## 💻 CLI

```powershell
# Récupère la liste
aws sns list-topics --region REGION

# Copie l'ARN du topic

# Supprime
aws sns delete-topic `
  --topic-arn SNS_TOPIC_ARN `
  --region REGION

# Vérifie
aws sns list-topics --region REGION
```

---

# 1️⃣4️⃣ CLOUDWATCH LOGS

## 🖥️ Dashboard

```
1. AWS Console → CloudWatch → Log Groups

2. Sélectionne chaque log group:
   /aws/lambda/LAMBDA_FUNCTION_1
   /aws/lambda/LAMBDA_FUNCTION_2
   /aws/ecs/SERVICE_NAME
   (et autres...)

3. Pour chaque:
   → Clique "Delete log group"
   → Confirme
```

## 💻 CLI

```powershell
# Récupère les log groups
aws logs describe-log-groups --region REGION

# Supprime chaque groupe
aws logs delete-log-group --log-group-name /aws/lambda/LAMBDA_FUNCTION_1 --region REGION
aws logs delete-log-group --log-group-name /aws/lambda/LAMBDA_FUNCTION_2 --region REGION
aws logs delete-log-group --log-group-name /aws/ecs/SERVICE_NAME --region REGION

# Vérifie
aws logs describe-log-groups --region REGION
```

---

# 1️⃣5️⃣ AWS GLUE JOBS

## 🖥️ Dashboard

```
1. AWS Console → Glue → Jobs

2. Sélectionne le job

3. Clique "Delete"
   → Confirme

4. Glue → Databases
   → Sélectionne la database
   → Clique "Delete"
```

## 💻 CLI

```powershell
# Récupère les Glue jobs
aws glue list-jobs --region REGION

# Supprime le job
aws glue delete-job --job-name JOB_NAME --region REGION

# Supprime la database
aws glue delete-database --name DATABASE_NAME --region REGION

# Vérifie
aws glue list-jobs --region REGION
```

---

# ✅ VÉRIFICATION FINALE

## Script de vérification complet

```powershell
# ========================================
# VERIFICATION - RIEN NE DOIT TOURNER
# ========================================

# EC2 Instances (running)
aws ec2 describe-instances --region REGION --query "Reservations[].Instances[?State.Name=='running'].InstanceId" --output text

# RDS
aws rds describe-db-instances --region REGION --query "DBInstances[].DBInstanceIdentifier" --output text

# Lambda
aws lambda list-functions --region REGION --query "Functions[].FunctionName" --output text

# ECS Clusters
aws ecs list-clusters --region REGION --query "clusterArns" --output text

# ECR
aws ecr describe-repositories --region REGION --query "repositories[].repositoryName" --output text

# S3 Buckets
aws s3 ls

# Step Functions
aws stepfunctions list-state-machines --region REGION --query "stateMachines[].name" --output text

# SNS Topics
aws sns list-topics --region REGION --query "Topics[].TopicArn" --output text

# Auto Scaling Groups
aws autoscaling describe-auto-scaling-groups --region REGION --query "AutoScalingGroups[].AutoScalingGroupName" --output text

# Load Balancers
aws elbv2 describe-load-balancers --region REGION --query "LoadBalancers[].LoadBalancerArn" --output text

# Launch Templates
aws ec2 describe-launch-templates --region REGION --query "LaunchTemplates[].LaunchTemplateName" --output text
```

**Tout doit afficher VIDE!** ✓

---

# 💰 RÉSUMÉ

| Ressource | Status |
|-----------|--------|
| EC2 Instances | ✓ Supprimé |
| RDS Database | ✓ Supprimé |
| Lambda Functions | ✓ Supprimé |
| API Gateway | ✓ Supprimé |
| ECS Cluster | ✓ Supprimé |
| ECR Repository | ✓ Supprimé |
| S3 Buckets | ✓ Supprimé |
| Step Functions | ✓ Supprimé |
| SNS Topics | ✓ Supprimé |
| CloudWatch Logs | ✓ Supprimé |
| Glue Jobs | ✓ Supprimé |
| Auto Scaling Groups | ✓ Supprimé |
| Load Balancers | ✓ Supprimé |
| Launch Templates | ✓ Supprimé |
| Athena Database | ✓ Supprimé |

**COÛT FINAL: $0/mois** 💚

---

# 🎯 ORDRE RECOMMANDÉ

1. **ECS + ECR**
2. **Step Functions**
3. **Lambda + API Gateway**
4. **Auto Scaling + Load Balancer**
5. **Launch Templates**
6. **EC2 Instances**
7. **RDS**
8. **S3 Buckets**
9. **Athena**
10. **SNS**
11. **CloudWatch Logs**
12. **Glue**

---

## 📝 CHECKLIST SUPPRESSION

- [ ] Étape 1 : ECS
- [ ] Étape 2 : ECR
- [ ] Étape 3 : Step Functions
- [ ] Étape 4 : Lambda
- [ ] Étape 5 : API Gateway
- [ ] Étape 6 : Auto Scaling Groups
- [ ] Étape 7 : Load Balancers
- [ ] Étape 8 : Launch Templates
- [ ] Étape 9 : EC2 Instances
- [ ] Étape 10 : RDS
- [ ] Étape 11 : S3 Buckets
- [ ] Étape 12 : Athena
- [ ] Étape 13 : SNS
- [ ] Étape 14 : CloudWatch Logs
- [ ] Étape 15 : Glue Jobs
- [ ] Vérification finale
- [ ] Tout est supprimé ✓

---

**Fait la suppression dans cet ordre pour éviter les erreurs!** 🚀
