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