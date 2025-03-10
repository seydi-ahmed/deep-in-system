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
- générer une paire de clés ssh sur l'ordinateur local (pas le serveur)
    - ssh-keygen -t rsa -b 4096 -C "luffy@samaserver"
- clé générée
    - ``````
- copier la clé publique sur le serveur
    - ssh-copy-id -i ~/.ssh/id_rsa.pub luffy@11.11.90.149 -p 2222

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

## Configuration des sauvegardes