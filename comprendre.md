10.0.2.15

1. Configuration du réseau

Tu dois configurer une adresse IP statique pour ton serveur.
Étape 1.1 : Configurer une IP statique

    Ouvre le fichier de configuration réseau :
    bash
    Copy

    sudo nano /etc/netplan/01-netcfg.yaml

    Modifie le fichier pour qu'il ressemble à ceci (remplace 192.168.1.100 par l'IP statique de ton choix et 192.168.1.1 par la passerelle de ton réseau) :
    yaml
    Copy

    network:
      version: 2
      ethernets:
        enp0s3:  # Remplace par le nom de ton interface réseau (utilise `ip a` pour le vérifier)
          dhcp4: no
          addresses:
            - 192.168.1.100/24
          gateway4: 192.168.1.1
          nameservers:
            addresses: [8.8.8.8, 8.8.4.4]

    Applique les modifications :
    bash
    Copy

    sudo netplan apply

    Vérifie que tu as accès à Internet :
    bash
    Copy

    ping -c 5 google.com

2. Sécurisation du serveur
Étape 2.1 : Désactiver la connexion root à distance via SSH

    Ouvre le fichier de configuration SSH :
    bash
    Copy

    sudo nano /etc/ssh/sshd_config

    Trouve la ligne PermitRootLogin et modifie-la comme suit :
    bash
    Copy

    PermitRootLogin no

    Sauvegarde et ferme le fichier, puis redémarre le service SSH :
    bash
    Copy

    sudo systemctl restart ssh

Étape 2.2 : Changer le port SSH

    Dans le même fichier /etc/ssh/sshd_config, trouve la ligne Port et modifie-la :
    bash
    Copy

    Port 2222

    Sauvegarde, ferme le fichier, et redémarre SSH :
    bash
    Copy

    sudo systemctl restart ssh

Étape 2.3 : Configurer le pare-feu (UFW)

    Installe UFW si ce n'est pas déjà fait :
    bash
    Copy

    sudo apt update
    sudo apt install ufw

    Autorise le port SSH (2222) et les ports nécessaires (HTTP, FTP, etc.) :
    bash
    Copy

    sudo ufw allow 2222/tcp
    sudo ufw allow 80/tcp  # Pour HTTP
    sudo ufw allow 21/tcp  # Pour FTP

    Active le pare-feu :
    bash
    Copy

    sudo ufw enable

    Vérifie l'état du pare-feu :
    bash
    Copy

    sudo ufw status

3. Gestion des utilisateurs
Étape 3.1 : Créer l'utilisateur luffy (authentification par clé SSH)

    Crée l'utilisateur :
    bash
    Copy

    sudo adduser luffy

    Ajoute luffy au groupe sudo :
    bash
    Copy

    sudo usermod -aG sudo luffy

    Génère une paire de clés SSH sur ton ordinateur local (pas sur le serveur) :
    bash
    Copy

    ssh-keygen -t rsa -b 4096 -C "luffy@samserver"

    Copie la clé publique sur le serveur :
    bash
    Copy

    ssh-copy-id -i ~/.ssh/id_rsa.pub luffy@192.168.1.100 -p 2222

Étape 3.2 : Créer l'utilisateur zoro (authentification par mot de passe)

    Crée l'utilisateur :
    bash
    Copy

    sudo adduser zoro

    Définis un mot de passe pour zoro (tu peux utiliser diouf ou un autre mot de passe).

4. Installation des services
Étape 4.1 : Installer un serveur FTP (vsftpd)

    Installe vsftpd :
    bash
    Copy

    sudo apt update
    sudo apt install vsftpd

    Ouvre le fichier de configuration :
    bash
    Copy

    sudo nano /etc/vsftpd.conf

    Modifie les lignes suivantes :
    bash
    Copy

    anonymous_enable=NO
    local_enable=YES
    write_enable=NO

    Crée l'utilisateur nami :
    bash
    Copy

    sudo adduser nami

    Restreins l'accès de nami au dossier /backup :
    bash
    Copy

    sudo usermod -d /backup nami
    sudo chown root:root /backup
    sudo chmod 755 /backup

Étape 4.2 : Installer MySQL

    Installe MySQL :
    bash
    Copy

    sudo apt install mysql-server

    Sécurise MySQL :
    bash
    Copy

    sudo mysql_secure_installation

    Crée un utilisateur MySQL pour WordPress :
    bash
    Copy

    sudo mysql -u root -p
    CREATE DATABASE wordpress;
    CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
    FLUSH PRIVILEGES;
    EXIT;

Étape 4.3 : Installer WordPress

    Installe Apache et PHP :
    bash
    Copy

    sudo apt install apache2 php libapache2-mod-php php-mysql

    Télécharge WordPress :
    bash
    Copy

    cd /var/www/html
    sudo wget https://wordpress.org/latest.tar.gz
    sudo tar -xvzf latest.tar.gz
    sudo mv wordpress/* .
    sudo rm -rf wordpress latest.tar.gz

    Configure WordPress :
    bash
    Copy

    sudo nano wp-config.php

    Remplis les informations de la base de données (nom de la base, utilisateur, mot de passe).

5. Configuration des sauvegardes
Étape 5.1 : Créer un cron job pour sauvegarder la base de données WordPress

    Crée un script de sauvegarde :
    bash
    Copy

    sudo nano /usr/local/bin/backup.sh

    Ajoute ceci :
    bash
    Copy

    #!/bin/bash
    DATE=$(date +%Y-%m-%d)
    mysqldump -u wpuser -p'password' wordpress > /backup/wordpress-$DATE.sql
    echo "Backup successful at $(date)" >> /var/log/backup.log

    Rend le script exécutable :
    bash
    Copy

    sudo chmod +x /usr/local/bin/backup.sh

    Ajoute une tâche cron :
    bash
    Copy

    sudo crontab -e

    Ajoute cette ligne :
    bash
    Copy

    0 0 * * * /usr/local/bin/backup.sh