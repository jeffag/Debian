# Installer Cockpit et des modules complémentaires
sudo apt install -y cockpit cockpit-machines cockpit-networkmanager cockpit-pcp cockpit-storaged cockpit-podman

# Activer et démarrer le service
sudo systemctl enable --now cockpit.socket

# Vérifie que ça tourne
sudo systemctl status cockpit

# Ouvrir le port (si tu as un firewall actif, ex. ufw)
#sudo ufw allow 9090/tcp

echo "Rendre le script exécutable : chmod +x Install_Cockpit.sh "
echo
echo "Utilisation : " 
echo "Accéder à Cockpit dans un navigateur :" 
echo "soit en local https://localhost:9090 ou https://127.0.0.1:9090"
echo "Depuis une autre machine du réseau avec https://IP_DE_TA_MACHINE:9090"

