# WiFi Cracker Termux

Un script Bash pour Termux permettant de scanner, capturer et cracker les réseaux Wi-Fi.

## Fonctionnalités
- Scanner les réseaux Wi-Fi disponibles
- Capturer un handshake
- Crackeur de mot de passe (Bruteforce)
- Télécharger des wordlists du Dark Web

## Installation
1. Installez Termux depuis [F-Droid](https://f-droid.org/en/packages/com.termux/).
2. Exécutez les commandes suivantes :
   ```bash
   termux-setup-storage
   pkg install aircrack-ng tor wget -y
   git clone https://github.com/votre-repo/wifi-cracker-termux
   cd wifi-cracker-termux
   chmod +x wifi_cracker_termux.sh
   ./wifi_cracker_termux.sh
