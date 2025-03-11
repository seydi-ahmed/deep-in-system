# deep-in-system

## Installation de la machine virtuelle
1) Télacharger Ubuntu Server LTS
- Aller sur ```https://ubuntu.com/download/server``` et télécharger la derniére version LTS
- Préparer une machine virtuelle avec 30GB de disque

2) Création de la VM
- Ouvrir VirtualBox
- Configuration de la VM:
    - 2 CPU
    - 4 Go de Ram
    - 30 Go de stockage de disque dur
    - Mode réseau: NAT
    - user: diouf
    - usermane: diouf
    - hostname: diouf-host

3) Partitionnement du disque
Pendant l'installation d'ubuntu server
- /swap : 4G      
- / (root) : 15G
- /home : 5G
- /backup : 6G

## Suivre les étapes
Aprés avoir redémarrer la machine, installer le nécessaire avec ```sudo apt install net-tools```

## Configuration reéseau
1) Définir une adresse ip statique
- regarder le fichier de configuration par défaut dans /etc/netplan
- modifier le fichier
    - sudo nano /etc/netplan/50-cloud-init.yaml (ou peu importe le nom du fichier)
    - ajouter l'adresse ip voulu(avec le masque), le gateway et le serveur
    - quitter
    - sudo netplan apply (pour appliquer le changement)
2) tester
- ping google.com

## Sécurisation du serveur
1) Désactiver la connextion root à distance via ssh
- sudo nano /etc/ssh/sshd_config
- changer la ligne 1 par la ligne 2
    - ligne 1: #PermitRootLogin prohibit-password
    - ligne 2: PermitRootLogin no
- redémarrer ssh
    - sudo systemctl restart ssh

2) Changer le port ssh
- dans le même fichier, changer le port en 2222

3) Configurer le pare-feu (UFW)
- installer ufw
    - sudo apt update
    - sudo apt install ufw
- autoriser le port ssh et les ports nécessaires (http, ftp, ...)
    - sudo ufw allow 2222/tcp
    - sudo ufw allow 80/tcp (pour http)
    - sudo ufw allow 21/tcp (pour ftp)
- activer le pare-feu
    - sudo ufw enable
- vérifier l'état du pare-feu
    - sudo ufx status

## Gestion des utilisateurs
1) Luffy:
- créer l'utilisateur
    - sudo adduser luffy
- ajouter luffy au groupe sudo
    - sudo usermod -aG sudo luffy
- aller dans mon ordi perso (celui de luffy)
- générer une paire de clés ssh sur l'ordinateur local (pas le serveur)
    - ssh-keygen -t rsa -b 4096 -C "luffy@samaserver"
- copier la clé publique sur le serveur
    - ssh-copy-id -i ~/.ssh/id_rsa.pub -p2222 luffy@11.11.90.149

2) zoro:
- créer l'utilisateur zoro
    - sudo adduser zoro

## Installation des services
1) Installer vsftpd
- sudo apt update
- sudo apt install vsftpd
2) Ouvrir le fichier de configuration
- sudo nano etc/vsftpd.conf
- modifier les lignes suivantes
    - anonymou_enable=NO
    - local_enable=YES
    - write_enable=NO
3) Créer l'utilisateur nami
- sudo adduser nami
4) Restreindre l'accés de nami au dossier backup
- sudo usermod -d /backup nami
- sudo chown root:root /backup
- sudo chmod 755 /backup

5) Installer et Sécuriser MySQL
- sudo apt install mysql-server
- sudo mysql_secure_installation
- créer un utilisateur mysql pour wordpress
    - sudo mysql -u root -p
    - create database wordpress;
    - create user "wpuser@localhost" identified by "wpuser";
        - le mot de passe est "dioufWPUSER/7"
    - grant all privileges on wordpress.* to "wpuser@localhost";
    - flush privileges;
    - exit;

6) Installer apache, php et wordpress 
- ```sudo apt install apache2 php libapache2-mod-php php-mysql```
- ```cd /var/www/html```
- ```sudo wget https://wordpress.org/latest.tar.gz```
- ```sudo tar -xvzf latest.tar.gz```
- ```sudo mv wordpres/* .```
- ```sudo rm -rf wordpress latest.tar.gz```
- configurer
    - ```sudo nano wp-config-sample.php```
    - remplir les infos de la base de données (nom, utilisateur, mot de passe)
- password pour wordpress: 7cNiDUH)9)tRn!v@0c


## Configuration des sauvegardes
1) Créer un script de sauvegarde
- ```sudo nano /usr/local/bin/backup.sh```
- y mettre ceci
```
#!/bin/bash
DATE=$(date +%Y-%m-%d)
mysqldump -u wpuser -p'password' wordpress > /backup/wordpress-$DATE.sql
echo "Backup successful at $(date)" >> /var/log/backup.log
```
2) Rendre le script exécutable
- ```sudo chmod +x /usr/local/bin/backup.sh```

3) Ajouter une tâche cron
- sudo crontab -e
- met ceci:
    - ```0 0 * * * /usr/local/bin/backup.sh```

## Questions / Réponses
1) sudo group en linux
- c'est un groupe qui permet d'exécuter des commandes avec des priviléges administrateurs
2) netplan
- il configure le réseau de la machine
    - enp0S3: interface réseau utilisé
    - addresses: adresse ip fixe de la machine
    - routes: le gateway qui permet d'accéder à d'autres réseaux
    - nameserves: définit les serveurs DNS
3) netmask:
- il définit quelle partie de l'adresse ip correspond aux réseaux et quelle partie correspond aux machines
4) ip static:
- permet aux utilisateurs d'accéder aux serveurs sans interruption
- nécessaire pour les services qui utilise tout le temps le serveur
5) ssh secure
- sudo cat /etc/ssh/sshd_config
- port 2222 pour plus de sécurité
- accés à root via ssh désactivé
6) le serveur et son rôle
- il permet de se connecter à distance de maniére sécurisée
- gérer un serveur à distance
7) ports ouverts
- 2222 pour avoir accés à ssh
- 80 pour utiliser le service web
- 21 pour le ftp
- 40K / 50K pour le ftp en mode passif
8) ftp
- mode actif: le serveur initie une connexion vers le client
- mode passif: le client initie une connexion vers le serveur
9) MySQL
- fermé pour des raisons de sécurité. n'est utilisé que par le serveur (wordpress)
10) firewall:
- il contrôle le trafic réseau entrant et sortant
- filtre les accés pour assurer la sécurité
11) cronjob
- une tâche planifiée qui s'exécute à des intervalles de temps réguliers
- automatiser les tâches répétitives
12) crontab:
- c'est le fichier qui permet de gérer les cronjobs
13) backup
- protége contre les pertes de données, les attaques etc.

## Développeur:
- Prénom NOM: Mouhamed DIOUF
- email: seydiahmedelcheikh@gmail.com