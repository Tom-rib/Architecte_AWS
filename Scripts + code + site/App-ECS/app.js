const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Page d'accueil
app.get('/', (req, res) => {
  res.json({
    message: 'Bienvenue sur mon app ECS Fargate!',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    hostname: os.hostname()
  });
});

// Health check pour ECS/ALB
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Info sur l'environnement
app.get('/info', (req, res) => {
  res.json({
    nodeVersion: process.version,
    platform: process.platform,
    arch: process.arch,
    uptime: Math.floor(process.uptime()) + ' seconds',
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB',
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + ' MB'
    }
  });
});

// Démarrer le serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
});
