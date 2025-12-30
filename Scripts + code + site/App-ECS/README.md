# Mon App ECS Fargate 🐳

Application Node.js prête à déployer sur AWS ECS Fargate.

## 📁 Structure

```
mon-app-ecs/
├── app.js              ← Application Express
├── package.json        ← Dépendances Node.js
├── Dockerfile          ← Image Docker
├── .dockerignore       ← Fichiers exclus du build
└── aws/
    ├── task-definition.json   ← Config ECS (⚠️ remplacer ACCOUNT_ID)
    └── trust-policy.json      ← IAM trust policy
```

## ⚠️ AVANT DE COMMENCER

Remplacer `ACCOUNT_ID` dans les fichiers :
- `aws/task-definition.json` (2 endroits)

Pour trouver ton Account ID :
```bash
aws sts get-caller-identity --query Account --output text
```

## 🚀 Étapes rapides

### 1. Test local
```bash
npm install
npm start
# Ouvrir http://localhost:3000
```

### 2. Build Docker
```bash
docker build -t mon-app-ecs .
docker run -p 3000:3000 mon-app-ecs
```

### 3. Déployer sur AWS
Suivre le guide étape par étape avec Claude !

## 📍 Endpoints

| Route | Description |
|-------|-------------|
| `/` | Page d'accueil |
| `/health` | Health check |
| `/info` | Infos système |

## 🔧 Configuration

| Variable | Défaut | Description |
|----------|--------|-------------|
| `PORT` | 3000 | Port du serveur |

## 📊 Ressources AWS créées

- ECR Repository : `mon-app-ecs`
- ECS Cluster : `mon-cluster`
- Task Definition : `mon-app-ecs-task`
- Service : `mon-app-ecs-service`
- Security Group : `ecs-sg`
- Log Group : `/ecs/mon-app-ecs`
