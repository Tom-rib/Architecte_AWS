# Job 5 : CloudWatch + SNS Monitoring 📊

Mémo rapide pour monitorer tous vos services AWS et recevoir des alertes en temps réel.

**Format :** Dashboard AWS (clics) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts de base
- **[CloudWatch Basics](./01-CloudWatch-Concepts-Complets.md)** - Qu'est-ce que CloudWatch ?
- **[SNS Basics](./02-SNS-Concepts-Complets.md)** - Qu'est-ce que SNS ?
- **[Logs vs Metrics vs Alarms](./01-CloudWatch-Concepts-Complets.md#types)** - Différences clés

### Monitoring Détaillé
- **[Logs Avancés](./03-Logs-Avances.md)** - Logs, requêtes, rétention
- **[Metrics Avancées](./04-Metrics-Avances.md)** - Métriques personnalisées, mathématiques
- **[Alarms Avancées](./05-Alarms-Avances.md)** - Alarmes complexes, composite alarms
- **[Dashboards](./06-Dashboards.md)** - Créer visualisations

### Monitoring par Service
- **[EC2 Monitoring](./08-EC2-Monitoring-Complet.md)** - CPU, réseau, disque, RAM
- **[Lambda Monitoring](./09-Lambda-Monitoring-Complet.md)** - Durée, erreurs, throttles
- **[RDS Monitoring](./10-RDS-Monitoring-Complet.md)** - Connexions, latency, CPU
- **[API Gateway Monitoring](./11-API-Gateway-Monitoring.md)** - Erreurs, latence

### Avancé
- **[Custom Metrics](./07-Custom-Metrics.md)** - Envoyer métriques personnalisées
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS

### Référence
- **[Troubleshooting](./Troubleshooting.md)** - Problèmes courants

---

## 🎯 FLUX RAPIDE

```
BASES :
1. Créer Topic SNS (02-SNS-Concepts-Complets.md)
2. S'abonner par email
3. Créer 1ère alarme (05-Alarms-Avances.md)

OPTIONNEL :
4. Dashboards (06-Dashboards.md)
5. Custom metrics (07-Custom-Metrics.md)
6. Scripts CLI (CLI-Commands.md)

AVANCÉ :
7. Monitoring cross-service
8. Composite alarms
9. Automation
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Coût |
|---------|---------|------|
| **CloudWatch Logs** | Logs de tous les services | Gratuit (5GB/mois) |
| **CloudWatch Metrics** | Graphiques (CPU, RAM, durée, etc) | Gratuit (basic) |
| **CloudWatch Alarms** | Alertes automatiques | 10 GRATUIT |
| **SNS Topic** | Canal de notification | Gratuit (1000 messages) |
| **SNS Email** | Recevoir alertes par email | GRATUIT |
| **Custom Metrics** | Vos propres métriques | 0.30€/mois (50 first free) |
| **Dashboards** | Visualisation | Gratuit (3 first) |
| **Log Insights** | Requêtes avancées | 0.55€/GB analysé |

---

## 📊 MONITORING PAR SERVICE

| Service | Métriques Clés | Alarmes Recommandées |
|---------|---|---|
| **EC2** | CPU, Réseau, Disque | CPU >80%, Réseau anormal |
| **Lambda** | Durée, Erreurs, Invocations | Erreurs >1%, Throttles >0 |
| **RDS** | Connexions, CPU, Latency | CPU >80%, Connexions >80% |
| **API Gateway** | Erreurs 4xx/5xx, Latence | Erreurs >5%, Latence >1s |
| **S3** | Requêtes, Erreurs | Erreurs >5% |
| **DynamoDB** | Read/Write Capacity, Throttles | Throttles >0 |

---

## 🚀 BESOIN D'AIDE RAPIDE ?

**Débutant ?**
- Qu'est-ce que CloudWatch ? → [01-CloudWatch-Concepts-Complets.md](./01-CloudWatch-Concepts-Complets.md)
- Qu'est-ce que SNS ? → [02-SNS-Concepts-Complets.md](./02-SNS-Concepts-Complets.md)
- Créer une alarme ? → [05-Alarms-Avances.md](./05-Alarms-Avances.md)

**Intermédiaire ?**
- Logs avancés ? → [03-Logs-Avances.md](./03-Logs-Avances.md)
- Métriques personnalisées ? → [07-Custom-Metrics.md](./07-Custom-Metrics.md)
- Dashboards ? → [06-Dashboards.md](./06-Dashboards.md)

**Avancé ?**
- Alarmes complexes ? → [05-Alarms-Avances.md](./05-Alarms-Avances.md#composite)
- EC2 monitoring ? → [08-EC2-Monitoring-Complet.md](./08-EC2-Monitoring-Complet.md)
- Lambda monitoring ? → [09-Lambda-Monitoring-Complet.md](./09-Lambda-Monitoring-Complet.md)
- RDS monitoring ? → [10-RDS-Monitoring-Complet.md](./10-RDS-Monitoring-Complet.md)

**Problèmes ?**
- Alarmes ne se déclenchent pas ? → [Troubleshooting.md](./Troubleshooting.md)
- Alertes manquées ? → [Troubleshooting.md](./Troubleshooting.md)
- Coûts élevés ? → [04-Metrics-Avances.md](./04-Metrics-Avances.md#coût)

- Utiliser CLI ? → [CLI-Commands.md](./CLI-Commands.md)

---

## 📌 NOTES IMPORTANTES

- **Région** : `eu-west-3` (Paris)
- **Free tier** : 10 alarmes + 1000 notifications SNS GRATUIT
- **Logs** : 5GB/mois gratuit
- **Metrics** : Gratuites (basic)
- **Email** : Vous devez confirmer l'abonnement SNS
- **SNS Topic** : Réutilisable pour plusieurs alarmes
- **Retention logs** : 30 jours par défaut (configurable)
- **Métriques personnalisées** : 50 first free, puis 0.30€/mois

---

## 🎁 BONUS

### Cas d'usage courants

| Cas | Solution |
|-----|----------|
| Alerter sur EC2 CPU élevé | Alarme CloudWatch + SNS email |
| Tracer erreurs Lambda | CloudWatch Logs Insights |
| Monitorer RDS performance | RDS Enhanced Monitoring |
| Graphique personnalisé | Dashboard CloudWatch |
| Alertes multiples sur 1 topic | 1 Topic SNS + plusieurs alarmes |
| Alerte si plusieurs erreurs | Composite Alarm |
| Alerte sur métrique custom | Custom Metric + Alarme |

---

## 🔗 LIENS UTILES

- **Voir GUIDE-SETUP-JOB5.md** : Configuration rapide pour le projet (10 alarmes optimisées)
- **AWS Masterclass** (futur) : Documentation AWS complète

---

**Créé pour maîtriser CloudWatch et SNS rapidement** 📚

[⬅️ Retour au Job 4](../Job4-Lambda-API/README.md)
