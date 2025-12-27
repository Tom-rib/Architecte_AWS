# Elastic IP - IP fixe 🌐

Adresse IP publique fixe. Ne change jamais, même si vous arrêtez l'instance.

---

## 🎯 À quoi ça sert ?

- DNS pointant vers IP (domaine.com)
- Intégrations tiers (whitelist IP)
- Multi-instance failover
- Applications critiques

---

## 📊 Comparaison

| | Public IP | Elastic IP |
|---|---|---|
| **IP** | Change chaque arrêt/redémarrage | Fixe |
| **Coût** | 0 (gratuit) | 0€/mois si attachée, 3€ si détachée |
| **Association** | Auto | Manuel |
| **Cas** | Dev/test | Production |
| **Exemple** | 54.123.45.67 → 54.234.56.78 | 54.123.45.67 → toujours même |

---

## 🖼️ DASHBOARD AWS

### Allouer une Elastic IP

```
1. EC2 > Elastic IPs
2. Allocate Elastic IP address
3. Network border group : eu-west-3 (ou votre région)
4. Allocate ✓
5. Vous avez maintenant une IP fixe
```

### Attacher à une Instance

```
1. Elastic IPs > Sélectionnez
2. Associate Elastic IP address
3. Instance : sélectionnez votre EC2
4. Private IP : auto (ou spécifiez)
5. Associate ✓
```

### Voir vos Elastic IPs

```
EC2 > Elastic IPs
- Public IP : votre IP fixe
- Instance : attachée ou non
- Status : Associated / Not associated
```

### Détacher d'une Instance

```
1. Elastic IPs > Sélectionnez
2. Disassociate Elastic IP address
3. Disassociate ✓
4. L'instance garde l'IP temporaire
5. Elastic IP devient "Not associated"
```

### Libérer une Elastic IP

```
1. Elastic IPs > Sélectionnez
2. Release Elastic IP address
3. Release ✓
4. Vous ne payez plus
```

---

## 💻 CLI

### Allouer une Elastic IP

```bash
aws ec2 allocate-address --region eu-west-3
# Retourne : PublicIp, AllocationId, Domain
```

### Lister les Elastic IPs

```bash
aws ec2 describe-addresses
```

### Attacher à une Instance

```bash
aws ec2 associate-address \
  --instance-id i-0123456789abcdef0 \
  --allocation-id eipalloc-0123456789abcdef0
```

### Détacher d'une Instance

```bash
aws ec2 disassociate-address \
  --association-id eipassoc-0123456789abcdef0
```

### Libérer une Elastic IP

```bash
aws ec2 release-address \
  --allocation-id eipalloc-0123456789abcdef0
```

---

## 💡 BONNES PRATIQUES

- **Allouer quand vous en avez besoin** (coûts)
- **Libérer si vous n'utilisez plus** (3€/mois sinon)
- **Une par instance critique** (pas besoin pour test)
- **Documenter l'IP** (dans DNS, notes, etc)

---

[⬅️ Retour](./README.md)
