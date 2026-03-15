# 🕵️‍♂️ Forensics Labs - 100% CLI Container

> ⚠️ **Note personnelle** : Ce projet est le fruit de mon propre apprentissage. Je ne suis pas encore un expert et je continue d'apprendre chaque jour, que ce soit sur Docker ou sur les analyses Forensics. Il est donc tout à fait possible que cet environnement ne soit pas parfait et qu'il y ait des mises à jour à l'avenir au fil de ma progression. Les retours constructifs sont les bienvenus ! 😄

## 📝 Description

Cet environnement Docker (déployé via Docker Compose) a été conçu pour fournir un conteneur d'analyse **Digital Forensics and Incident Response (DFIR)** robuste, léger et 100% en ligne de commande (CLI). 

Il se destine aux analystes SOC/CSIRT, aux joueurs de CTF (Capture The Flag) et aux passionnés de cybersécurité souhaitant un environnement isolé et "prêt à l'emploi" pour manipuler des preuves numériques (images disques, dumps mémoire, pcap, fichiers suspects, etc..). 

Basée sur **Debian Stable Slim**, l'image est optimisée pour minimiser la surface d'attaque et regroupe un arsenal d'outils standards du marché catégorisés par type d'analyse.

## 🛠️ Outils Inclus

Les outils sont divisés en plusieurs couches pour optimiser le temps de build et la lisibilité du `Containerfile`.

### 1. 💽 Analyse Disques & Systèmes de Fichiers (Forensics)
* **The Sleuth Kit (TSK)** : Suite d'outils pour l'investigation de systèmes de fichiers (NTFS, FAT, ext, etc..).
* **TestDisk** : Récupération de données et réparation de partitions.
* **xxd** / **hashdeep** : Hexdump, création et vérification de hash d'intégrité (MD5, SHA, etc..).

### 2. 📂 Extraction, Stéganographie & Analyse de Fichiers
* **binwalk** / **foremost** : Rétro-ingénierie granulaire et *file carving* (extraction de fichiers dissimulés).
* **exiftool** : Lecture et modification des métadonnées.
* **steghide** : Analyse classique de stéganographie (JPEG, WAV, etc.).
* **pngcheck** : Vérification de l'intégrité des chunks PNG (très utile en CTF).
* **zbar-tools** : Décodage en ligne de commande de codes-barres et de QR codes.
* **YARA** : Recherches de signatures de comportements malveillants.
* **radare2** : Framework complet de reverse engineering.
* **file** / **jq** : Identification de type de fichier, parsing et traitement JSON.

### 3. 🌐 Analyse Réseau
* **tshark** / **tcpdump** : Analyseurs de trafic réseau (CLI de Wireshark).
* **ngrep** : Recherche par expressions régulières (Regex) directement dans un flux ou pcap.

### 4. 🧠 Analyse Mémoire RAM (Volatility)
L'environnement configure proprement les références absolues à Volatility :
* **Volatility 3** (raccourci `vol`) : Récupéré via Github, installé dans un environnement virtuel Python (`venv`) isolé pour éviter tout conflit de dépendance avec le reste du système.
* **Volatility 2** (raccourci `vol2`) : Version Standalone `2.6_lin64` téléchargée pour une utilisation sur des très vieux dumps Windows XP/7 n'étant plus nécessairement supportés dans la v3.

## 📂 Structure du projet

* `Containerfile` : Recette Dockerfile multi-calques (Layers) des dépendances.
* `compose.yaml` : Configuration du déploiement Docker.
* `Work/` : Espace partagé contenant vos preuves. **(Généré automatiquement lors du premier lancement, voir section Utilisation)**.

## 🔒 Sécurité : L'Isolation Réseau (Mode Paranoïa)

Afin qu'un conteneur puisse analyser des données potentiellement infectées (malwares, ransomwares, droppers) de manière **sécurisée**, ce fichier `compose.yaml` intègre par défaut l'option `network_mode: none`. 
Cela désactive complètement la carte réseau du conteneur. Le malware ne peut joindre aucun C2 (Command & Control). 

> **Note :** Si l'environnement doit servir de couteau suisse pour jouer sur une plateforme de type HackTheBox ou ROOT ME (Cas CTF) sans risque infectieux, commentez `network_mode: none` et décommentez `# network_mode: host` dans le fichier `compose.yaml` pour activer la résolution internet.

De plus, le conteneur est lancé en intégrant la capabilitée `SYS_ADMIN` de Docker (`cap_add: SYS_ADMIN`), élément indispensable si vous avez l'intention de monter manuellement une image de disque brute dans un système de fichiers virtuel pour l'analyser (commande `mount -o loop`).

## 🚀 Utilisation

1. **Cloner le repository** :
```bash
git clone https://github.com/SolarRoot75/Forensics_Labs.git
cd Forensics_Labs
```

2. **Lancement via Docker Compose** :
```bash
# Pour construire l'image et instancier le démon Linux en arrière-plan
docker compose up -d --build
```

3. **Entrer dans le laboratoire Forensics** :
Le conteneur possède l'instruction `tty: true` et `stdin_open: true`, ce qui permet au CLI de rester allumé à l'infini (via bash) après chargement.
```bash
docker exec -it forensics-labs /bin/bash
```

> 💡 **Utilisateur de Podman ?**
> Ce conteneur (basé sur le standard OCI avec `Containerfile`) a été originellement pensé pour **Podman** (notamment sur des OS immuables comme Bazzite/Fedora Silverblue). Il est **100% compatible** avec les deux moteurs sur n'importe quelle distribution Linux ! Remplacez simplement `docker compose` par `podman-compose` dans vos commandes.

> 💡 **Le Saviez-vous ?** Les dossiers `Work/evidence` et `Work/output` de votre hôte sont désormais en prise directe *(mount points)* dans votre conteneur sous la racine `/work`. Vous pouvez injecter vos fichiers `.dd`, `.E01`, `.pcap`, `.mem` depuis votre machine et les retrouver immédiatement dans le shell du conteneur en tapant `ls /work`. Les extractions y seront également conservées !
