# HTTPS - Certificat SSL 🔒

Sécuriser les connexions avec HTTPS.

---

## 🎯 À quoi ça sert ?

- Chiffrer les données en transit
- Authentifier le serveur
- Satisfaire les navigateurs modernes
- Confiance des utilisateurs

---

## 📊 Types de certificats

| | Self-signed | Let's Encrypt | AWS ACM |
|---|---|---|---|
| **Coût** | Gratuit | Gratuit | Gratuit |
| **Validation** | Aucune | Email/DNS | Automatique |
| **Navigateur** | Avertissement | Vert | Vert |
| **Cas** | Test/dev | Production | Production AWS |
| **Durée** | 1 an | 3 mois | 1 an |

**Pour ce job : Self-signed (test)**

---

## 🖼️ DASHBOARD AWS

### Générer Certificat (SSH)

```
SSH à votre instance :

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt \
  -subj "/C=FR/ST=France/L=Paris/O=MyOrg/CN=aws.local"

✓ Certificat créé
```

### Configurer Nginx (SSH)

```
sudo nano /etc/nginx/sites-available/default
```

Remplacer tout par :

```nginx
# HTTP → HTTPS
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://$host$request_uri;
}

# HTTPS
server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    root /var/www/html;
    index index.php index.html index.htm;
    server_name _;
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
```

Sauvegarder : Ctrl+O, Enter, Ctrl+X

### Tester et Redémarrer (SSH)

```bash
sudo nginx -t
# Retour : syntax is ok

sudo systemctl restart nginx
```

### Security Group

```
EC2 > Security Groups
- Port 443 : HTTPS (0.0.0.0/0)
```

### Importer dans Certificate Manager (OPTIONNEL)

```
AWS Certificate Manager > Import certificate
- Certificate body : contenu du .crt
- Certificate private key : contenu du .key
- Import ✓
```

Puis attacher au Load Balancer :
- Ajouter listener 443 HTTPS
- Sélectionnez certificat

---

## 💻 CLI

### Générer Certificat

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt \
  -subj "/C=FR/ST=France/L=Paris/O=MyOrg/CN=aws.local"
```

### Vérifier Certificat

```bash
openssl x509 -in /etc/ssl/certs/nginx-selfsigned.crt -text -noout
```

### Télécharger (depuis PC)

```powershell
scp -i "C:\aws-keys\aws_arch.pem" admin@IP:/etc/ssl/certs/nginx-selfsigned.crt C:\Users\Tom\
scp -i "C:\aws-keys\aws_arch.pem" admin@IP:/etc/ssl/private/nginx-selfsigned.key C:\Users\Tom\
```

---

## 📌 NOTES

- **Self-signed** : navigateur affiche avertissement (normal, c'est du test)
- **Proceeding anyway** : cliquer pour continuer (en dev)
- **Load Balancer + HTTPS** : attacher certificat AWS ACM au listener 443
- **Renouvellement** : Self-signed expire après 365j (créer nouveau)

---

[⬅️ Retour](./README.md)
