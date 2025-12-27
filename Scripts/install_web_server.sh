#!/bin/bash
#################################################################
# Script: install_web_server.sh
# Description: Installation automatique d'Apache et PHP sur Amazon Linux 2023
# Usage: sudo bash install_web_server.sh
#################################################################

set -e  # Arrêter en cas d'erreur

echo "🚀 Début de l'installation du serveur web..."

# 1. Mise à jour du système
echo "📦 Mise à jour du système..."
yum update -y

# 2. Installation d'Apache et PHP
echo "🌐 Installation d'Apache et PHP..."
yum install -y httpd php php-common php-cli

# 3. Démarrage et activation d'Apache
echo "▶️  Démarrage d'Apache..."
systemctl start httpd
systemctl enable httpd

# 4. Vérification du statut
if systemctl is-active --quiet httpd; then
    echo "✅ Apache est démarré avec succès"
else
    echo "❌ Erreur: Apache n'a pas démarré"
    exit 1
fi

# 5. Création de la page web avec métadonnées EC2
echo "📄 Création de la page web..."

cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Projet AWS - EC2 Auto Scaling</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
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
            animation: fadeIn 0.5s ease-in;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
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
            transition: transform 0.3s ease;
        }
        
        .info-card:hover {
            transform: translateY(-5px);
        }
        
        .info-label {
            font-size: 0.9em;
            opacity: 0.9;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
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
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.8; }
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
        
        .timestamp {
            text-align: center;
            margin-top: 20px;
            color: #999;
            font-size: 0.85em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Projet AWS</h1>
        <h2>Application Web avec Auto Scaling & Load Balancer</h2>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Instance ID</div>
                <div class="info-value">
                    <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'); ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Availability Zone</div>
                <div class="info-value">
                    <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone'); ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">IP Privée</div>
                <div class="info-value">
                    <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4'); ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">IP Publique</div>
                <div class="info-value">
                    <?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/public-ipv4') ?: 'N/A'; ?>
                </div>
            </div>
        </div>
        
        <div class="status">
            ✅ Serveur opérationnel
        </div>
        
        <div class="timestamp">
            Dernière mise à jour : <?php echo date('d/m/Y H:i:s'); ?>
        </div>
        
        <div class="footer">
            Projet AWS - Administration Systèmes et Réseaux<br>
            Architecture: EC2 | Auto Scaling | Load Balancer | CloudWatch
        </div>
    </div>
</body>
</html>
EOF

# 6. Configuration des permissions
echo "🔒 Configuration des permissions..."
chown apache:apache /var/www/html/index.php
chmod 644 /var/www/html/index.php

# 7. Test final
echo "🧪 Test de l'installation..."
if curl -s http://localhost | grep -q "Projet AWS"; then
    echo "✅ Installation réussie ! La page web est accessible."
else
    echo "⚠️  Attention: La page web ne semble pas accessible localement"
fi

echo ""
echo "=========================================="
echo "✅ Installation terminée avec succès !"
echo "=========================================="
echo ""
echo "📝 Informations:"
echo "  - Apache version: $(httpd -v | head -1)"
echo "  - PHP version: $(php -v | head -1)"
echo "  - Fichier web: /var/www/html/index.php"
echo ""
echo "🌐 Pour tester:"
echo "  - Localement: curl http://localhost"
echo "  - Navigateur: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo ""