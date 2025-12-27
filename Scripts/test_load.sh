#!/bin/bash
#################################################################
# Script: test_load.sh
# Description: Teste la charge sur l'infrastructure AWS
# Usage: ./test_load.sh <URL_DU_LOAD_BALANCER>
#################################################################

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier les arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Erreur: URL manquante${NC}"
    echo "Usage: $0 <URL_DU_LOAD_BALANCER>"
    echo "Exemple: $0 http://webapp-prod-alb-123456.eu-west-3.elb.amazonaws.com"
    exit 1
fi

URL=$1

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   🧪 TEST DE CHARGE AWS INFRASTRUCTURE${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "🎯 Cible: ${GREEN}$URL${NC}"
echo ""

# Test 1: Vérification de disponibilité
echo -e "${YELLOW}📡 Test 1: Vérification de disponibilité${NC}"
if curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200"; then
    echo -e "${GREEN}✅ Le serveur est accessible (HTTP 200)${NC}"
else
    echo -e "${RED}❌ Le serveur ne répond pas correctement${NC}"
    exit 1
fi
echo ""

# Test 2: Répartition de charge
echo -e "${YELLOW}⚖️  Test 2: Répartition de charge (10 requêtes)${NC}"
echo "Instance IDs détectés:"

for i in {1..10}; do
    INSTANCE=$(curl -s $URL | grep -oP 'Instance ID.*?i-[a-z0-9]+' | head -1)
    echo "  Requête $i: $INSTANCE"
    sleep 0.5
done
echo ""

# Test 3: Temps de réponse
echo -e "${YELLOW}⏱️  Test 3: Mesure du temps de réponse (5 tests)${NC}"
TOTAL_TIME=0
for i in {1..5}; do
    TIME=$(curl -s -o /dev/null -w "%{time_total}" $URL)
    echo "  Test $i: ${TIME}s"
    TOTAL_TIME=$(echo "$TOTAL_TIME + $TIME" | bc)
    sleep 0.5
done
AVG_TIME=$(echo "scale=3; $TOTAL_TIME / 5" | bc)
echo -e "Temps moyen: ${GREEN}${AVG_TIME}s${NC}"
echo ""

# Test 4: Test de charge avec curl
echo -e "${YELLOW}🔥 Test 4: Test de charge (100 requêtes)${NC}"
echo "Envoi de 100 requêtes..."

SUCCESS=0
FAIL=0
START=$(date +%s)

for i in {1..100}; do
    if curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200"; then
        ((SUCCESS++))
    else
        ((FAIL++))
    fi
    
    # Afficher la progression tous les 10 requêtes
    if [ $((i % 10)) -eq 0 ]; then
        echo -n "."
    fi
done

END=$(date +%s)
DURATION=$((END - START))

echo ""
echo -e "✅ Succès: ${GREEN}$SUCCESS/100${NC}"
echo -e "❌ Échecs: ${RED}$FAIL/100${NC}"
echo -e "⏱️  Durée: ${DURATION}s"
echo -e "📊 Taux de réussite: ${GREEN}$SUCCESS%${NC}"
echo ""

# Test 5: Test avec Apache Bench (si disponible)
if command -v ab &> /dev/null; then
    echo -e "${YELLOW}📊 Test 5: Apache Bench (500 requêtes, 10 concurrentes)${NC}"
    ab -n 500 -c 10 $URL/ 2>&1 | grep -E "(Requests per second|Time per request|Failed requests)"
    echo ""
else
    echo -e "${YELLOW}📊 Test 5: Apache Bench${NC}"
    echo -e "${RED}⚠️  Apache Bench (ab) n'est pas installé${NC}"
    echo "Installation:"
    echo "  - Linux: sudo apt install apache2-utils"
    echo "  - Mac: brew install apr-util"
    echo ""
fi

# Résumé
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}          📋 RÉSUMÉ DES TESTS${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "✅ Disponibilité: ${GREEN}OK${NC}"
echo -e "✅ Répartition de charge: ${GREEN}Testée${NC}"
echo -e "✅ Temps de réponse moyen: ${GREEN}${AVG_TIME}s${NC}"
echo -e "✅ Taux de réussite: ${GREEN}$SUCCESS%${NC}"
echo ""

if [ $SUCCESS -eq 100 ]; then
    echo -e "${GREEN}🎉 Tous les tests ont réussi !${NC}"
else
    echo -e "${YELLOW}⚠️  Certains tests ont échoué. Vérifie:${NC}"
    echo "  - Les instances EC2 sont bien 'Healthy' dans le Target Group"
    echo "  - Apache tourne sur toutes les instances"
    echo "  - Les Security Groups sont correctement configurés"
fi
echo ""

# Conseils pour tester l'auto-scaling
echo -e "${BLUE}📈 Pour tester l'Auto Scaling:${NC}"
echo ""
echo "1. Connecte-toi à une instance:"
echo "   ssh -i ta-cle.pem ec2-user@IP_INSTANCE"
echo ""
echo "2. Génère de la charge CPU:"
echo "   sudo yum install -y stress-ng"
echo "   stress-ng --cpu 2 --timeout 300s"
echo ""
echo "3. Surveille dans la console AWS:"
echo "   - CloudWatch Alarms (CPU > 70%)"
echo "   - Auto Scaling Group Activity"
echo "   - Nouvelles instances qui se lancent"
echo ""