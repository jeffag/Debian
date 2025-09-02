#!/bin/bash
set -euo pipefail

# ----- Vérifs de base -----
[ "$EUID" -eq 0 ] || { echo "Lance ce script en root (sudo -i)"; exit 1; }
if ! grep -qi '^ID=debian' /etc/os-release; then
  echo "Attention: ce script est prévu pour Debian."; exit 1
fi

# ----- Entrées -----
read -rp "Nom du nouvel utilisateur : " USERNAME
id "$USERNAME" &>/dev/null && { echo "L'utilisateur '$USERNAME' existe déjà."; exit 1; }

read -rsp "Mot de passe pour $USERNAME : " PASS1; echo
read -rsp "Confirme le mot de passe : " PASS2; echo
[ "$PASS1" = "$PASS2" ] || { echo "❌ Mots de passe différents"; exit 1; }

read -rp "Nom complet (facultatif) : " COMMENT || true

# ----- Préparer sudo & groupe -----
if ! dpkg -s sudo &>/dev/null; then
  apt-get update -y
  apt-get install -y sudo
fi

getent group sudo >/dev/null 2>&1 || groupadd sudo

# ----- Création de l'utilisateur -----
if command -v adduser >/dev/null 2>&1; then
  # Debian: adduser crée le home et pose les droits corrects
  adduser --disabled-password --gecos "${COMMENT:-,,,}" "$USERNAME"
else
  useradd -m -s /bin/bash -c "${COMMENT:-}" "$USERNAME"
fi

# Définir le mot de passe
echo "$USERNAME:$PASS1" | chpasswd

# Ajout au groupe sudo
usermod -aG sudo "$USERNAME"

# ----- (Optionnel) Déployer une clé SSH -----
read -rp "Souhaites-tu ajouter une clé SSH publique maintenant ? (o/N) " ADDKEY
if [[ "${ADDKEY:-N}" =~ ^[oOyY]$ ]]; then
  read -rp "Colle la clé publique (ssh-ed25519/ssh-rsa...) : " PUBKEY
  homedir=$(getent passwd "$USERNAME" | cut -d: -f6)
  install -d -m 700 -o "$USERNAME" -g "$USERNAME" "$homedir/.ssh"
  echo "$PUBKEY" >> "$homedir/.ssh/authorized_keys"
  chown "$USERNAME:$USERNAME" "$homedir/.ssh/authorized_keys"
  chmod 600 "$homedir/.ssh/authorized_keys"
fi

# ----- Sanity checks -----
echo
echo "---- RÉSUMÉ ----"
echo "Utilisateur : $USERNAME"
echo "Nom complet : ${COMMENT:-<non défini>}"
echo "Groupes     : $(id -nG "$USERNAME")"
echo "Shell       : $(getent passwd "$USERNAME" | cut -d: -f7)"
echo
echo "✅ Terminé. '$USERNAME' peut utiliser sudo."
echo "Astuce: teste avec -> su - $USERNAME ; sudo whoami"



# Rendre le script exécutable : chmod +x creer_utilisateur_sudo.sh

# Utilisation en root : ./creer_utilisateur_sudo.sh username (si sudo ne répond pas c'est qu'il n'est pas installé, donc il s'installera.


# Installer Cockpit et des modules complémentaires
#sudo apt install -y cockpit cockpit-machines cockpit-networkmanager cockpit-pcp cockpit-storaged cockpit-podman

# Activer et démarrer le service
#sudo systemctl enable --now cockpit.socket

# Vérifie que ça tourne
#sudo systemctl status cockpit

# Ouvrir le port (si tu as un firewall actif, ex. ufw)
#sudo ufw allow 9090/tcp

#Accéder à Cockpit dans un navigateur : soit https://localhost:9090 ou https://127.0.0.1:9090 , Depuis une autre machine du réseau avec https://IP_DE_TA_MACHINE:9090
