#!/bin/bash
#################################################################
# user-data.sh
# Script de démarrage automatique pour instances EC2
# À utiliser dans le Launch Template ou lors de la création d'instance
#################################################################

# Ce script s'exécute automatiquement au démarrage de l'instance
# Il installe et configure Apache avec PHP

# Logs de démarrage
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "====================================="
echo "Début du script user-data"
echo "Date: $(date)"
echo "====================================="

# 1. Mise à jour du système
echo "[1/5] Mise à jour du système..."
yum update -y

# 2. Installation d'Apache et PHP
echo "[2/5] Installation d'Apache et PHP..."
yum install -y httpd php php-common php-cli

# 3. Démarrage et activation d'Apache
echo "[3/5] Démarrage d'Apache..."
systemctl start httpd
systemctl enable httpd

# 4. Configuration du DirectoryIndex pour PHP
echo "[4/5] Configuration d'Apache pour PHP..."
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf

# 5. Création de la page web avec métadonnées
echo "[5/5] Création de la page web..."

cat > /var/www/html/index.php << 'EOFHTML'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS - Auto Scaling Demo</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 50px;
            max-width: 800px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 10px;
            text-align: center;
        }
        h2 {
            color: #764ba2;
            font-size: 1.5em;
            margin-bottom: 30px;
            text-align: center;
            font-weight: 300;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .info-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            border-radius: 10px;
            color: white;
        }
        .info-label {
            font-size: 0.9em;
            opacity: 0.9;
            margin-bottom: 5px;
            text-transform: uppercase;
        }
        .info-value {
            font-size: 1.3em;
            font-weight: bold;
            word-break: break-all;
        }
        .status {
            text-align: center;
            padding: 20px;
            background: #4caf50;
            color: white;
            border-radius: 10px;
            font-size: 1.2em;
            margin-top: 30px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS Auto Scaling</h1>
        <h2>Application Web Distribuée</h2>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Instance ID</div>
                <div class="info-value">
                    <?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/instance-id') ?: 'N/A'; ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Availability Zone</div>
                <div class="info-value">
                    <?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone') ?: 'N/A'; ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">IP Privée</div>
                <div class="info-value">
                    <?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4') ?: 'N/A'; ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Région</div>
                <div class="info-value">
                    <?php 
                        $az = @file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone');
                        echo $az ? substr($az, 0, -1) : 'N/A';
                    ?>
                </div>
            </div>
        </div>
        
        <div class="status">
            ✅ Instance opérationnelle
        </div>
        
        <div class="footer">
            Projet AWS - EC2 Auto Scaling & Load Balancer<br>
            Rafraîchis la page pour voir la répartition de charge
        </div>
    </div>
</body>
</html>
EOFHTML

# Configuration des permissions
chown apache:apache /var/www/html/index.php
chmod 644 /var/www/html/index.php

# Redémarrage d'Apache pour prendre en compte les changements
systemctl restart httpd

echo "====================================="
echo "✅ Script user-data terminé avec succès"
echo "Date: $(date)"
echo "====================================="

# Test final
if systemctl is-active --quiet httpd; then
    echo "✅ Apache est actif"
else
    echo "❌ Erreur: Apache n'est pas actif"
fi