# Job 9 : Step Functions + Lambda + CloudWatch 🔄

Mémo rapide pour orchestrer des workflows serverless complexes avec Step Functions.

**Format :** Dashboard AWS (clics) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts de base
- **[Step Functions Basics](./01-StepFunctions-Concepts-Complets.md)** - Qu'est-ce que Step Functions ?
- **[Lambda pour Workflows](./02-Lambda-Workflows.md)** - Lambda dans Step Functions
- **[ASL - States Language](./03-ASL-States-Language.md)** - Le langage de définition
- **[Types d'états](./03-ASL-States-Language.md#types)** - Task, Choice, Parallel, etc.

### Création de Workflows
- **[États Task](./04-Task-States.md)** - Appeler Lambda, services AWS
- **[États de contrôle](./05-Control-States.md)** - Choice, Parallel, Map, Wait
- **[Gestion des erreurs](./06-Error-Handling.md)** - Retry, Catch, Fallback
- **[Input/Output Processing](./07-IO-Processing.md)** - InputPath, ResultPath, OutputPath

### Monitoring
- **[CloudWatch Integration](./08-CloudWatch-Integration.md)** - Logs et métriques
- **[X-Ray Tracing](./09-XRay-Tracing.md)** - Traçage distribué
- **[Alarmes](./08-CloudWatch-Integration.md#alarmes)** - Alertes sur échecs

### Avancé
- **[Express vs Standard](./10-Express-vs-Standard.md)** - Quel type choisir ?
- **[Patterns courants](./11-Patterns.md)** - Saga, Circuit Breaker, etc.
- **[Intégrations AWS](./12-AWS-Integrations.md)** - DynamoDB, SQS, SNS direct

### Référence
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS
- **[Troubleshooting](./Troubleshooting.md)** - Problèmes courants

---

## 🎯 FLUX RAPIDE

```
BASES :
1. Créer fonctions Lambda (02-Lambda-Workflows.md)
2. Créer State Machine (01-StepFunctions-Concepts-Complets.md)
3. Définir le workflow ASL (03-ASL-States-Language.md)
4. Tester l'exécution

ROBUSTESSE :
5. Ajouter gestion erreurs (06-Error-Handling.md)
6. Configurer retries (06-Error-Handling.md#retry)
7. Ajouter états fallback

MONITORING :
8. Activer CloudWatch Logs (08-CloudWatch-Integration.md)
9. Créer alarmes (08-CloudWatch-Integration.md#alarmes)
10. Activer X-Ray (optionnel)
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Coût |
|---------|---------|------|
| **State Machine** | Définition du workflow | 4000 transitions GRATUITES/mois |
| **Execution** | Instance du workflow en cours | Inclus dans transitions |
| **State** | Étape du workflow | - |
| **Task** | État qui fait quelque chose | Appel Lambda/service |
| **Choice** | Branchement conditionnel | GRATUIT |
| **Parallel** | Exécution en parallèle | 1 transition par branche |
| **Map** | Itération sur une liste | 1 transition par item |
| **Wait** | Pause temporisée | GRATUIT |
| **Retry** | Réessayer en cas d'erreur | Transitions additionnelles |
| **Catch** | Capturer les erreurs | 1 transition |

---

## 🔄 ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                      STEP FUNCTIONS                          │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                 STATE MACHINE                        │    │
│  │                                                      │    │
│  │    ┌──────────────┐                                 │    │
│  │    │ ValidateInput│ (Task - Lambda)                 │    │
│  │    └──────┬───────┘                                 │    │
│  │           │                                          │    │
│  │           ▼                                          │    │
│  │    ┌──────────────┐                                 │    │
│  │    │  IsValid?    │ (Choice)                        │    │
│  │    └──────┬───────┘                                 │    │
│  │           │                                          │    │
│  │     ┌─────┴─────┐                                   │    │
│  │     ▼           ▼                                   │    │
│  │  ┌──────┐  ┌──────────┐                            │    │
│  │  │ Yes  │  │   No     │                            │    │
│  │  └──┬───┘  └────┬─────┘                            │    │
│  │     │           │                                   │    │
│  │     ▼           ▼                                   │    │
│  │  ┌──────────┐  ┌──────────┐                        │    │
│  │  │ProcessData│  │SendError │                        │    │
│  │  └────┬─────┘  └──────────┘                        │    │
│  │       │                                             │    │
│  │       ▼                                             │    │
│  │  ┌──────────────┐                                  │    │
│  │  │SendNotification│ (Task - Lambda)                │    │
│  │  └──────────────┘                                  │    │
│  │                                                      │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CLOUDWATCH                              │
│  • Logs d'exécution                                         │
│  • Métriques (succès, échecs, durée)                        │
│  • Alarmes                                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 TYPES D'ÉTATS

| État | Description | Exemple d'usage |
|------|-------------|-----------------|
| **Task** | Exécute une action | Appeler Lambda, DynamoDB |
| **Choice** | Branchement conditionnel | Si valide → process, sinon → erreur |
| **Parallel** | Branches en parallèle | Envoyer email ET SMS |
| **Map** | Itérer sur une liste | Traiter chaque commande |
| **Wait** | Attendre | Pause 5 minutes |
| **Pass** | Passer des données | Transformer input/output |
| **Succeed** | Fin avec succès | Terminer le workflow |
| **Fail** | Fin avec erreur | Terminer en échec |

---

## 🆚 STANDARD VS EXPRESS

| Aspect | Standard | Express |
|--------|----------|---------|
| **Durée max** | 1 an | 5 minutes |
| **Débit** | 2000 exec/sec | 100 000 exec/sec |
| **Prix** | Par transition | Par exécution + durée |
| **Historique** | 90 jours | CloudWatch Logs |
| **Exactly-once** | ✅ Oui | ❌ At-least-once |
| **Idéal pour** | Workflows longs | ETL, streaming |

---

## 🚀 BESOIN D'AIDE RAPIDE ?

**Débutant ?**
- Qu'est-ce que Step Functions ? → [01-StepFunctions-Concepts-Complets.md](./01-StepFunctions-Concepts-Complets.md)
- Créer des Lambda pour workflows ? → [02-Lambda-Workflows.md](./02-Lambda-Workflows.md)
- Comprendre ASL ? → [03-ASL-States-Language.md](./03-ASL-States-Language.md)

**Intermédiaire ?**
- États Task ? → [04-Task-States.md](./04-Task-States.md)
- Branchements et parallélisme ? → [05-Control-States.md](./05-Control-States.md)
- Gestion des erreurs ? → [06-Error-Handling.md](./06-Error-Handling.md)
- Input/Output ? → [07-IO-Processing.md](./07-IO-Processing.md)

**Avancé ?**
- Standard vs Express ? → [10-Express-vs-Standard.md](./10-Express-vs-Standard.md)
- Patterns d'architecture ? → [11-Patterns.md](./11-Patterns.md)
- Intégrations directes ? → [12-AWS-Integrations.md](./12-AWS-Integrations.md)

**Problèmes ?**
- Exécution échoue ? → [Troubleshooting.md](./Troubleshooting.md)
- Lambda timeout ? → [Troubleshooting.md](./Troubleshooting.md#lambda)
- Permissions IAM ? → [Troubleshooting.md](./Troubleshooting.md#iam)
- Commandes CLI ? → [CLI-Commands.md](./CLI-Commands.md)

---

## 📌 NOTES IMPORTANTES

- **Région** : `eu-west-3` (Paris)
- **Free tier** : 4000 transitions/mois GRATUIT (permanent)
- **Standard** : $0.025 par 1000 transitions (après free tier)
- **Express** : $1.00 par million d'exécutions + $0.00001667/GB-sec
- **Lambda** : Facturé séparément
- **CloudWatch Logs** : Facturé séparément
- **IAM** : Rôle nécessaire pour invoquer Lambda
- **Timeout Lambda** : Max 15 min (Step Functions attend)
- **Payload max** : 256 KB entre états

---

## 🎁 BONUS

### Cas d'usage courants

| Cas | Solution |
|-----|----------|
| Valider → Traiter → Notifier | Workflow séquentiel (Task → Task → Task) |
| Traiter si valide, sinon erreur | Choice state avec conditions |
| Envoyer email ET SMS | Parallel state |
| Traiter chaque item d'une liste | Map state |
| Attendre approbation humaine | Wait + callback pattern |
| Réessayer en cas d'erreur | Retry avec backoff exponentiel |
| Rollback si échec | Catch + états de compensation (Saga) |
| Limiter les appels API | Wait entre les appels |

### Workflow exemple (3 Lambda)

```
Input → ValidateInput → ProcessData → SendNotification → Output
           ↓ (erreur)
        HandleError → Fail
```

---

## 🔗 LIENS UTILES

- **Voir GUIDE-SETUP-JOB9.md** : Configuration étape par étape du projet
- **Job 4 - Lambda + API Gateway** : Pour créer des Lambda
- **Job 5 - CloudWatch + SNS** : Pour le monitoring

---

**Créé pour maîtriser Step Functions rapidement** 📚

[⬅️ Retour au Job 8](../Job8-ECS-Fargate-ECR/README.md)
