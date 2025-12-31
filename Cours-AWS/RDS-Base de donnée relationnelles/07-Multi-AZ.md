# Multi-AZ - Haute Disponibilité 🔄

Répliquer BD dans autre zone pour failover automatique.

---

## 🎯 À quoi ça sert ?

- Si zone AWS tombe = bascule auto à autre zone
- Zéro downtime
- Coût : double (2 BD)

---

## 📊 Comparaison

| | Single AZ | Multi-AZ |
|---|---|---|
| **Disponibilité** | 99.9% | 99.95% ✓ |
| **Failover** | Manuel (30+ min) | Auto (< 2 min) ✓ |
| **Coût** | Normal | Double |
| **Cas** | Dev/test | Production |

---

## 🖼️ DASHBOARD AWS

### Activer Multi-AZ

```
1. RDS > Databases > my-database > Modify
2. Multi-AZ deployment : Yes
3. Standby AZ : automatique
4. Save ✓
5. Attendre sync (quelques min)
```

### Voir statut

```
RDS > Databases > my-database
- Multi-AZ : Yes
- Secondary AZ : eu-west-3b
```

### Tester failover

```
1. RDS > Databases > my-database
2. Actions > Reboot DB instance
3. ☑ Reboot with failover
4. Reboot ✓
5. Observe basculement (< 2 min)
```

---

## 💻 CLI

### Activer Multi-AZ

```bash
aws rds modify-db-instance \
  --db-instance-identifier my-database \
  --multi-az \
  --apply-immediately
```

### Tester failover

```bash
aws rds reboot-db-instance \
  --db-instance-identifier my-database \
  --force-failover
```

---

## 📌 NOTES

- **Coût** : double (2 instances)
- **Performance** : pas d'impact lecture
- **Replication** : synchrone (zéro perte données)
- **Failover** : < 2 minutes

---

[⬅️ Retour](./README.md)
