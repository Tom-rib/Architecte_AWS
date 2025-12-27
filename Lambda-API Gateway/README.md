# API RESTful Serverless Masterclass 🚀

Mémo rapide pour créer une API REST sans serveur avec Lambda, API Gateway et CloudWatch.

**Format :** Dashboard AWS (clics) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts de base
- **[Lambda Basics](./01-Lambda-Basics.md)** - Qu'est-ce que Lambda ?
- **[API Gateway Basics](./04-API-Gateway-Basics.md)** - Qu'est-ce que API Gateway ?
- **[CloudWatch Basics](./08-CloudWatch-Basics.md)** - Surveillance et monitoring

### Déploiement
- **[Créer Fonction Lambda](./02-Create-Lambda.md)** - Déployer une fonction (code Python/Node.js)
- **[Créer API REST](./05-Create-API.md)** - Créer et configurer une API
- **[CORS](./06-CORS.md)** - Activer cross-origin requests

### Configuration et Sécurité
- **[Environment Variables](./03-Environment.md)** - Variables d'environnement et secrets
- **[Authentification](./07-Authentication.md)** - API Keys, OAuth, Cognito, IAM

### Monitoring et Logs
- **[Lambda Logs](./09-Lambda-Logs.md)** - Visualiser et déboguer logs
- **[Metrics](./10-Metrics.md)** - Métriques performance (duration, erreurs)
- **[Alarms](./11-Alarms.md)** - Alertes automatiques

### Versioning et Production
- **[Versions](./12-Versions.md)** - Versioning des fonctions Lambda
- **[Aliases](./13-Aliases.md)** - Aliases (prod, dev, staging)
- **[Deployment](./14-Deployment.md)** - Infrastructure as Code (SAM)

### Référence
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS
- **[Troubleshooting](./15-Troubleshooting.md)** - Déboguer (502, 403, CORS, timeout)

---

## 🎯 FLUX RAPIDE

```
BASES :
1. Créer une Fonction Lambda (02-Create-Lambda.md)
2. Créer une API REST (05-Create-API.md)
3. Tester l'API (voir logs dans 09-Lambda-Logs.md)

OPTIONNEL :
4. CORS pour frontend (06-CORS.md)
5. Variables d'environnement (03-Environment.md)
6. Monitoring (10-Metrics.md)
7. Alertes (11-Alarms.md)

AVANCÉ :
8. Authentification API (07-Authentication.md)
9. Versioning (12-Versions.md)
10. Aliases prod/dev (13-Aliases.md)
11. Infrastructure as Code (14-Deployment.md)
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Coût |
|---------|---------|------|
| **Lambda Function** | Code sans serveur | 1M requêtes GRATUIT |
| **API Gateway** | Point d'entrée HTTP REST | 1M appels GRATUIT |
| **Runtime** | Environnement (Python 3.11, Node.js 18) | Inclus |
| **Handler** | Fonction entrypoint | Gratuit |
| **CloudWatch Logs** | Logs d'exécution | Gratuit (5GB/mois) |
| **CloudWatch Metrics** | Graphiques performance | Gratuit |
| **Timeout** | Durée max exécution | 15 min (900 sec) |
| **Memory** | RAM allouée | 128 MB - 10 GB |
| **Concurrency** | Limite requêtes parallèles | 1000 par défaut |
| **Cold Start** | Init première invocation | ~100-500ms (normal) |

---

## 📊 COMPARAISON : EC2 vs Lambda

| | EC2 | Lambda |
|---|---|---|
| **Setup** | 1h + config | 5 min |
| **Coût inactivité** | 24€/mois minimum | 0€ (idle) |
| **Scaling** | Manual + ASG | Auto instantané |
| **Durée max** | Illimitée | 15 minutes |
| **Idéal pour** | Apps 24/7 | APIs courtes |

---

## 🚀 BESOIN D'AIDE RAPIDE ?

**Débutant ?**
- Qu'est-ce que Lambda ? → [01-Lambda-Basics.md](./01-Lambda-Basics.md)
- Créer fonction Lambda ? → [02-Create-Lambda.md](./02-Create-Lambda.md)
- Créer API REST ? → [05-Create-API.md](./05-Create-API.md)

**Intermédiaire ?**
- CORS pour frontend ? → [06-CORS.md](./06-CORS.md)
- Configuration ? → [03-Environment.md](./03-Environment.md)
- Voir logs ? → [09-Lambda-Logs.md](./09-Lambda-Logs.md)
- Monitorer ? → [10-Metrics.md](./10-Metrics.md)

**Avancé ?**
- Authentification ? → [07-Authentication.md](./07-Authentication.md)
- Versioning ? → [12-Versions.md](./12-Versions.md)
- Aliases prod/dev ? → [13-Aliases.md](./13-Aliases.md)
- Infrastructure as Code ? → [14-Deployment.md](./14-Deployment.md)

**Problèmes ?**
- Erreur 502 ou 403 ? → [15-Troubleshooting.md](./15-Troubleshooting.md)
- CORS error ? → [06-CORS.md](./06-CORS.md)
- Timeout ? → [15-Troubleshooting.md](./15-Troubleshooting.md)

- Utiliser CLI ? → [CLI-Commands.md](./CLI-Commands.md)

---

## 📌 NOTES IMPORTANTES

- **Région** : `eu-west-3` (Paris)
- **Free tier** : 1M requêtes Lambda + 1M appels API/mois GRATUIT
- **Python runtime** : 3.11 (recommandé)
- **Node.js runtime** : 18.x ou 20.x (recommandé)
- **Timeout default** : 3 secondes (augmenter si besoin)
- **Memory default** : 128 MB (CPU proportionnel à mémoire)
- **CloudWatch Logs** : Gratuit (5GB free tier)
- **Cold start** : ~100-500ms première invocation (normal)

---

## 🎁 BONUS

### Cas d'usage courants

| Cas | Solution |
|-----|----------|
| API simple | Lambda + API Gateway |
| Frontend JavaScript | Ajouter CORS |
| Configuration externe | Environment Variables |
| Sécuriser l'API | API Key ou OAuth |
| Monitor performance | CloudWatch Metrics |
| Alerter sur erreurs | CloudWatch Alarms |
| Déployer en prod | Versions + Aliases |
| Infrastructure as Code | SAM (template.yaml) |

---

**Créé pour maîtriser Lambda et API Gateway rapidement** 📚

[⬅️ Retour au Job 3](../Job3-RDS/README.md)
