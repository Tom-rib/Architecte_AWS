# Security Groups - Firewall BD 🔒

Contrôler qui peut accéder à votre BD.

---

## 🎯 À quoi ça sert ?

- Autoriser EC2 à se connecter
- Restreindre accès par IP
- Port 3306 (MySQL) ou 5432 (PostgreSQL)

---

## 🖼️ DASHBOARD AWS

### Voir Security Group

```
1. RDS > Databases > my-database
2. VPC security groups > cliquez le groupe
3. Inbound rules > Edit
```

### Ajouter règle pour accès local

```
1. Edit inbound rules
2. Add rule :
   - Type : MySQL/Aurora
     (ou Custom TCP port 5432 pour PostgreSQL)
   - Protocol : TCP
   - Port : 3306
   - Source : 0.0.0.0/0 (partout)
     OU votre IP/32
3. Save ✓
```

**Recommandé : utiliser votre IP (plus sûr)**

```
Source : X.X.X.X/32
(remplacez X par votre IP)
```

---

## 💻 CLI

### Voir inbound rules

```bash
aws ec2 describe-security-groups \
  --group-ids sg-0123456789abcdef0
```

### Ajouter règle MySQL

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp \
  --port 3306 \
  --cidr 0.0.0.0/0
```

---

## 📌 NOTES

- **Port MySQL** : 3306
- **Port PostgreSQL** : 5432
- **Source 0.0.0.0/0** : ouvert au monde (moins sûr)
- **Source votre IP** : plus sûr
- **EC2 security group** : permet EC2 → RDS

---

[⬅️ Retour](./README.md)
