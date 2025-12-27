// ===== AFFICHER/MASQUER LES INFOS =====
function afficherInfo() {
    const infosSection = document.getElementById('infos');
    
    if (infosSection.style.display === 'none') {
        infosSection.style.display = 'block';
        // Scroll vers la section
        infosSection.scrollIntoView({ behavior: 'smooth' });
    } else {
        infosSection.style.display = 'none';
    }
}

// ===== VALIDER LE FORMULAIRE =====
function validerFormulaire(event) {
    event.preventDefault();
    
    // Récupérer les valeurs
    const nom = document.getElementById('nom').value;
    const email = document.getElementById('email').value;
    const message = document.getElementById('message').value;
    
    // Validation simple
    if (!nom || !email || !message) {
        alert('❌ Veuillez remplir tous les champs !');
        return;
    }
    
    // Validation email
    if (!validerEmail(email)) {
        alert('❌ Email invalide !');
        return;
    }
    
    // Afficher confirmation
    console.log('Données du formulaire :');
    console.log(`Nom: ${nom}`);
    console.log(`Email: ${email}`);
    console.log(`Message: ${message}`);
    
    // Afficher le message de confirmation
    const confirmation = document.getElementById('confirmation');
    confirmation.style.display = 'block';
    
    // Réinitialiser le formulaire
    document.querySelector('.contact-form').reset();
    
    // Masquer la confirmation après 5 secondes
    setTimeout(() => {
        confirmation.style.display = 'none';
    }, 5000);
}

// ===== VALIDER EMAIL =====
function validerEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}

// ===== EFFECTUER UNE ACTION AU CHARGEMENT DE LA PAGE =====
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Site chargé depuis S3 + CloudFront');
    console.log('📍 Région: eu-west-3 (Paris)');
    console.log('⚡ Distribué par: CloudFront (200+ serveurs mondiaux)');
    
    // Ajouter des event listeners aux liens du menu
    document.querySelectorAll('.nav-menu a').forEach(link => {
        link.addEventListener('click', function() {
            console.log(`Navigation vers: ${this.textContent}`);
        });
    });
});

// ===== AFFICHER L'HEURE DU SERVEUR (simulation) =====
function afficherHeure() {
    const maintenant = new Date();
    const heure = maintenant.toLocaleTimeString('fr-FR');
    console.log(`Heure actuelle: ${heure}`);
    return heure;
}

// ===== COMPTER LES VISITES (localStorage) =====
function compterVisites() {
    let visites = localStorage.getItem('visites') || 0;
    visites = parseInt(visites) + 1;
    localStorage.setItem('visites', visites);
    console.log(`🔍 Nombre de visites: ${visites}`);
    return visites;
}

// Appeler la fonction au chargement
compterVisites();
