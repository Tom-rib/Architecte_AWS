#!/bin/bash
#################################################################
# Script: cleanup_aws.sh
# Description: Supprime toutes les ressources AWS du projet
# Usage: ./cleanup_aws.sh
# Attention: Ce script supprime TOUT ! Fais une sauvegarde avant.
#################################################################

set -e

# Configuration
REGION="eu-west-3"
PROJECT_TAG="webapp-prod"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}=========================================${NC}"
echo -e "${RED}   ⚠️  SUPPRESSION DES RESSOURCES AWS${NC}"
echo -e "${RED}=========================================${NC}"
echo ""
echo -e "${YELLOW}Ce script va supprimer TOUTES les ressources du projet:${NC}"
echo "  - Auto Scaling Group"
echo "  - Load Balancer"
echo "  - Target Group"
echo "  - Instances EC2"
echo "  - AMI et Snapshots"
echo "  - Launch Template"
echo "  - Security Groups"
echo "  - Subnets, IGW, VPC"
echo ""
echo -e "${RED}⚠️  CETTE ACTION EST IRRÉVERSIBLE !${NC}"
echo ""

read -p "Continuer ? (tapez 'OUI' en majuscules pour confirmer) : " confirm

if [ "$confirm" != "OUI" ]; then
    echo -e "${GREEN}✅ Annulé. Aucune ressource n'a été supprimée.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🧹 Début du nettoyage...${NC}"
echo ""

# Fonction pour attendre
wait_seconds() {
    echo -ne "   Attente de $1 secondes..."
    sleep $1
    echo -e " ${GREEN}✓${NC}"
}

# 1. Supprimer Auto Scaling Group
echo -e "${YELLOW}1️⃣  Auto Scaling Group${NC}"
ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --region $REGION \
    --query "AutoScalingGroups[?contains(AutoScalingGroupName, '${PROJECT_TAG}')].AutoScalingGroupName" \
    --output text 2>/dev/null)

if [ ! -z "$ASG_NAME" ]; then
    echo "   Trouvé: $ASG_NAME"
    aws autoscaling delete-auto-scaling-group \
        --auto-scaling-group-name $ASG_NAME \
        --force-delete \
        --region $REGION
    echo -e "   ${GREEN}✅ Supprimé${NC}"
    wait_seconds 30
else
    echo -e "   ${BLUE}ℹ️  Aucun Auto Scaling Group trouvé${NC}"
fi

# 2. Supprimer Load Balancer
echo -e "${YELLOW}2️⃣  Load Balancer${NC}"
ALB_ARN=$(aws elbv2 describe-load-balancers --region $REGION \
    --query "LoadBalancers[?contains(LoadBalancerName, '${PROJECT_TAG}')].LoadBalancerArn" \
    --output text 2>/dev/null)

if [ ! -z "$ALB_ARN" ]; then
    echo "   Trouvé: $ALB_ARN"
    aws elbv2 delete-load-balancer \
        --load-balancer-arn $ALB_ARN \
        --region $REGION
    echo -e "   ${GREEN}✅ Supprimé${NC}"
    wait_seconds 30
else
    echo -e "   ${BLUE}ℹ️  Aucun Load Balancer trouvé${NC}"
fi

# 3. Supprimer Target Group
echo -e "${YELLOW}3️⃣  Target Group${NC}"
TG_ARN=$(aws elbv2 describe-target-groups --region $REGION \
    --query "TargetGroups[?contains(TargetGroupName, '${PROJECT_TAG}')].TargetGroupArn" \
    --output text 2>/dev/null)

if [ ! -z "$TG_ARN" ]; then
    echo "   Trouvé: $TG_ARN"
    aws elbv2 delete-target-group \
        --target-group-arn $TG_ARN \
        --region $REGION
    echo -e "   ${GREEN}✅ Supprimé${NC}"
else
    echo -e "   ${BLUE}ℹ️  Aucun Target Group trouvé${NC}"
fi

# 4. Supprimer instances EC2
echo -e "${YELLOW}4️⃣  Instances EC2${NC}"
INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION \
    --filters "Name=tag:Project,Values=webapp-aws" \
              "Name=instance-state-name,Values=running,stopped" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text 2>/dev/null)

if [ ! -z "$INSTANCE_IDS" ]; then
    echo "   Trouvé: $INSTANCE_IDS"
    aws ec2 terminate-instances \
        --instance-ids $INSTANCE_IDS \
        --region $REGION
    echo -e "   ${GREEN}✅ Instances en cours de terminaison${NC}"
    wait_seconds 60
else
    echo -e "   ${BLUE}ℹ️  Aucune instance trouvée${NC}"
fi

# 5. Supprimer Launch Template
echo -e "${YELLOW}5️⃣  Launch Template${NC}"
LT_ID=$(aws ec2 describe-launch-templates --region $REGION \
    --query "LaunchTemplates[?contains(LaunchTemplateName, '${PROJECT_TAG}')].LaunchTemplateId" \
    --output text 2>/dev/null)

if [ ! -z "$LT_ID" ]; then
    echo "   Trouvé: $LT_ID"
    aws ec2 delete-launch-template \
        --launch-template-id $LT_ID \
        --region $REGION
    echo -e "   ${GREEN}✅ Supprimé${NC}"
else
    echo -e "   ${BLUE}ℹ️  Aucun Launch Template trouvé${NC}"
fi

# 6. Supprimer AMI
echo -e "${YELLOW}6️⃣  AMI${NC}"
AMI_ID=$(aws ec2 describe-images --region $REGION \
    --owners self \
    --filters "Name=name,Values=*${PROJECT_TAG}*" \
    --query 'Images[*].ImageId' \
    --output text 2>/dev/null)

if [ ! -z "$AMI_ID" ]; then
    echo "   Trouvé: $AMI_ID"
    aws ec2 deregister-image \
        --image-id $AMI_ID \
        --region $REGION
    echo -e "   ${GREEN}✅ AMI désenregistrée${NC}"
else
    echo -e "   ${BLUE}ℹ️  Aucune AMI trouvée${NC}"
fi

# 7. Supprimer Snapshots
echo -e "${YELLOW}7️⃣  Snapshots${NC}"
SNAPSHOT_IDS=$(aws ec2 describe-snapshots --region $REGION \
    --owner-ids self \
    --filters "Name=description,Values=*${PROJECT_TAG}*" \
    --query 'Snapshots[*].SnapshotId' \
    --output text 2>/dev/null)

if [ ! -z "$SNAPSHOT_IDS" ]; then
    for SNAP_ID in $SNAPSHOT_IDS; do
        echo "   Suppression: $SNAP_ID"
        aws ec2 delete-snapshot \
            --snapshot-id $SNAP_ID \
            --region $REGION 2>/dev/null || true
    done
    echo -e "   ${GREEN}✅ Snapshots supprimés${NC}"
else
    echo -e "   ${BLUE}ℹ️  Aucun snapshot trouvé${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   ✅ NETTOYAGE AUTOMATIQUE TERMINÉ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  Ressources à supprimer MANUELLEMENT:${NC}"
echo ""
echo "1. Security Groups:"
echo "   - webapp-prod-sg-web"
echo "   - webapp-prod-sg-alb"
echo ""
echo "2. VPC et réseau:"
echo "   - Subnets"
echo "   - Internet Gateway"
echo "   - VPC (webapp-prod-vpc)"
echo ""
echo "3. CloudWatch:"
echo "   - Alarmes"
echo "   - Dashboard"
echo ""
echo "4. Key Pair (optionnel):"
echo "   - webapp-prod-keypair"
echo ""
echo -e "${BLUE}📖 Consulte docs/09_nettoyage.md pour les instructions détaillées${NC}"
echo ""
echo -e "${YELLOW}💰 N'oublie pas de vérifier ta facture AWS dans 24-48h !${NC}"
echo ""