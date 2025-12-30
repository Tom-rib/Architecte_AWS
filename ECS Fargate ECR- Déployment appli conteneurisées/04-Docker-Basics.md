# 04 - Docker Basics 🐳

Guide pour créer et gérer des images Docker pour ECS/Fargate.

---

## 🎯 QU'EST-CE QUE DOCKER ?

**Docker** = Plateforme pour conteneuriser des applications.

```
Docker = "Emballer une app avec toutes ses dépendances"
```

**Avantages :**
- Fonctionne partout (dev = prod)
- Isolation des dépendances
- Déploiement rapide
- Scalabilité facile

---

## 📝 VOCABULAIRE DOCKER

| Terme | Définition |
|-------|------------|
| **Image** | Template read-only (le blueprint) |
| **Container** | Instance en cours d'exécution |
| **Dockerfile** | Script pour créer une image |
| **Layer** | Couche de l'image (cacheable) |
| **Registry** | Stockage d'images (ECR, Docker Hub) |
| **Tag** | Version d'une image |

---

## 📄 DOCKERFILE

### Structure de base

```dockerfile
# Image de base
FROM node:18-alpine

# Répertoire de travail
WORKDIR /app

# Copier fichiers de dépendances
COPY package*.json ./

# Installer dépendances
RUN npm install --production

# Copier le code source
COPY . .

# Port exposé
EXPOSE 3000

# Commande de démarrage
CMD ["node", "app.js"]
```

### Instructions principales

| Instruction | Usage | Exemple |
|-------------|-------|---------|
| `FROM` | Image de base | `FROM node:18-alpine` |
| `WORKDIR` | Répertoire de travail | `WORKDIR /app` |
| `COPY` | Copier fichiers | `COPY . .` |
| `ADD` | Copier + décompresser | `ADD archive.tar.gz /app` |
| `RUN` | Exécuter commande (build) | `RUN npm install` |
| `CMD` | Commande par défaut | `CMD ["node", "app.js"]` |
| `ENTRYPOINT` | Point d'entrée fixe | `ENTRYPOINT ["python"]` |
| `EXPOSE` | Documenter le port | `EXPOSE 3000` |
| `ENV` | Variable d'environnement | `ENV NODE_ENV=production` |
| `ARG` | Variable de build | `ARG VERSION=1.0` |
| `USER` | Utilisateur non-root | `USER node` |
| `HEALTHCHECK` | Vérifier la santé | Voir ci-dessous |

---

## 🏗️ EXEMPLES PAR LANGAGE

### Node.js

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Installer dépendances d'abord (cache layer)
COPY package*.json ./
RUN npm ci --only=production

# Copier le code
COPY . .

# User non-root
USER node

EXPOSE 3000

CMD ["node", "app.js"]
```

### Python (Flask/FastAPI)

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Installer dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Java (Spring Boot)

```dockerfile
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Go

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -o main .

# Run stage
FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
```

---

## 🚀 COMMANDES DOCKER ESSENTIELLES

### Build

```bash
# Build basique
docker build -t ma-app .

# Build avec tag version
docker build -t ma-app:v1.0.0 .

# Build avec fichier Dockerfile différent
docker build -t ma-app -f Dockerfile.prod .

# Build avec arguments
docker build --build-arg VERSION=1.0 -t ma-app .

# Build sans cache
docker build --no-cache -t ma-app .
```

### Run (test local)

```bash
# Run basique
docker run ma-app

# Run avec port mapping
docker run -p 3000:3000 ma-app

# Run en arrière-plan
docker run -d -p 3000:3000 ma-app

# Run avec nom
docker run -d --name mon-container -p 3000:3000 ma-app

# Run avec variables d'environnement
docker run -e NODE_ENV=production -p 3000:3000 ma-app

# Run avec fichier .env
docker run --env-file .env -p 3000:3000 ma-app

# Run interactif
docker run -it ma-app /bin/sh
```

### Gestion containers

```bash
# Lister containers en cours
docker ps

# Lister tous les containers
docker ps -a

# Arrêter un container
docker stop mon-container

# Démarrer un container arrêté
docker start mon-container

# Supprimer un container
docker rm mon-container

# Logs d'un container
docker logs mon-container
docker logs -f mon-container  # Follow

# Exec dans un container
docker exec -it mon-container /bin/sh
```

### Gestion images

```bash
# Lister images
docker images

# Supprimer une image
docker rmi ma-app:v1.0.0

# Tag une image
docker tag ma-app:latest ma-app:v1.0.0

# Nettoyer images non utilisées
docker image prune

# Nettoyer tout (containers, images, networks)
docker system prune -a
```

---

## 🏷️ TAGGING POUR ECR

### Format ECR

```
<account-id>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>
```

### Workflow complet

```bash
# 1. Build local
docker build -t ma-app .

# 2. Tag pour ECR
docker tag ma-app:latest 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:latest
docker tag ma-app:latest 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:v1.0.0

# 3. Login ECR
aws ecr get-login-password --region eu-west-3 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.eu-west-3.amazonaws.com

# 4. Push
docker push 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:latest
docker push 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:v1.0.0
```

---

## 🩺 HEALTHCHECK

### Dans Dockerfile

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### Paramètres

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `--interval` | Fréquence du check | 30s |
| `--timeout` | Timeout du check | 30s |
| `--start-period` | Grâce au démarrage | 0s |
| `--retries` | Essais avant unhealthy | 3 |

### Exemples par framework

**Node.js/Express :**
```dockerfile
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
```

**Python/FastAPI :**
```dockerfile
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
```

**Sans curl (wget) :**
```dockerfile
HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

---

## 📁 .DOCKERIGNORE

Fichier `.dockerignore` pour exclure des fichiers du build :

```
# Node
node_modules
npm-debug.log

# Python
__pycache__
*.pyc
.venv
venv

# IDE
.idea
.vscode
*.swp

# Git
.git
.gitignore

# Docker
Dockerfile*
docker-compose*
.docker

# Tests
test
tests
coverage
.coverage

# Docs
README.md
docs

# Env files
.env
.env.*
*.local
```

---

## ⚡ OPTIMISATION

### Multi-stage builds

Réduire la taille de l'image finale :

```dockerfile
# Stage 1: Build
FROM node:18 AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### Images légères

| Image | Taille | Usage |
|-------|--------|-------|
| `node:18` | ~900 MB | Dev |
| `node:18-slim` | ~200 MB | Prod |
| `node:18-alpine` | ~110 MB | Prod optimisé |

### Layer caching

Mettre les fichiers qui changent peu en premier :

```dockerfile
# ✅ BON - package.json change rarement
COPY package*.json ./
RUN npm install
COPY . .

# ❌ MAUVAIS - tout rebuild à chaque changement
COPY . .
RUN npm install
```

---

## 🔒 SÉCURITÉ

### User non-root

```dockerfile
# Créer user
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

# Utiliser cet user
USER appuser
```

### Pas de secrets dans l'image

```dockerfile
# ❌ MAUVAIS
ENV DATABASE_PASSWORD=secret123

# ✅ BON - passer au runtime
# docker run -e DATABASE_PASSWORD=xxx ma-app
```

### Scan de vulnérabilités

```bash
# Avec Docker Scout
docker scout cves ma-app:latest

# ECR scan automatique
aws ecr start-image-scan \
  --repository-name ma-app \
  --image-id imageTag=latest
```

---

## ✅ CHECKLIST DOCKERFILE

```
□ Image de base légère (alpine, slim)
□ WORKDIR défini
□ .dockerignore configuré
□ Layer caching optimisé
□ User non-root
□ HEALTHCHECK configuré
□ Pas de secrets hardcodés
□ Multi-stage si nécessaire
□ EXPOSE documenté
□ CMD ou ENTRYPOINT défini
```

---

## 🔗 LIENS

- **ECR** → [03-ECR-Concepts-Complets.md](./03-ECR-Concepts-Complets.md)
- **Push vers ECR** → [06-Push-ECR.md](./06-Push-ECR.md)
- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)

---

[⬅️ Retour au README](./README.md)
