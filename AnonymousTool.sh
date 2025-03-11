#!/bin/bash

# Kolory terminala
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
purple='\033[1;35m'
cyan='\033[1;36m'
white='\033[1;37m'
reset='\033[0m'
bold='\033[1m'
underlined='\033[4m'

CHAT_FILE="chat.txt"
USER_FILE="user_info.txt"
USER_DB="users.txt"
WARNINGS_FILE="warnings.txt"
MUTED_FILE="muted_users.txt"

# Funkcja animacji
animate() {
    for i in {1..3}; do
        echo -ne "${yellow}Ładowanie${reset}."
        sleep 0.5
        echo -ne "."
        sleep 0.5
        echo -ne ".\n"
        sleep 0.5
    done
}

# Nagłówki sekcji
header() {
    title=$1
    clear
    echo -e "${purple}╔═════════════════════════════════╗"
    echo -e "║      ${white}$title${purple}        ║"
    echo -e "╚═════════════════════════════════╝${reset}"
}

# Funkcja rysująca ASCII art menu
ascii_menu() {
    echo -e "${cyan}██████╗ ███████╗██╗   ██╗███╗   ███╗███████╗██████╗"
    echo -e "${cyan}██╔══██╗██╔════╝██║   ██║████╗ ████║██╔════╝██╔══██╗"
    echo -e "${cyan}██████╔╝███████╗██║   ██║██╔████╔██║███████╗██████╔╝"
    echo -e "${cyan}██╔═══╝ ██╔════╝██║   ██║██║╚██╔╝██║╚════██║██╔═══╝"
    echo -e "${cyan}██║     ███████╗╚██████╔╝██║ ╚═╝ ██║███████║██║"
    echo -e "${cyan}╚═╝     ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝${reset}"
}

# Funkcja rejestracji nowego użytkownika
register() {
    clear
    header "REGISTER"
    
    echo -e "${cyan}=== Rejestracja nowego konta ===${reset}"
    read -p "Podaj email: " email

    # Sprawdzenie czy email już istnieje
    if grep -q "^$email|" "$USER_DB"; then
        echo -e "${red}Konto z tym emailem już istnieje!${reset}"
        sleep 2
        return
    fi

    read -sp "Podaj hasło: " password
    echo ""
    read -p "Wybierz nick: " nick

    # Zapis do bazy użytkowników
    echo "$email|$password|$nick" >> "$USER_DB"
    echo -e "${green}Konto utworzone! Możesz się teraz zalogować.${reset}"
    sleep 2
}

# Funkcja logowania
login() {
    clear
    header "LOGIN"
    
    echo -e "${cyan}=== Logowanie ===${reset}"

    while true; do
        read -p "Email: " email
        read -sp "Hasło: " password
        echo ""

        # Sprawdzenie czy użytkownik istnieje
        if grep -q "^$email|$password|" "$USER_DB"; then
            nick=$(grep "^$email|$password|" "$USER_DB" | cut -d '|' -f3)
            echo "$nick" > "$USER_FILE"
            echo -e "${green}Zalogowano jako $nick!${reset}"
            sleep 2
            break
        else
            echo -e "${red}Nieprawidłowy email lub hasło!${reset}"
            sleep 2
        fi
    done
}

# Funkcja wysyłania wiadomości
send_message() {
    nick=$(cat "$USER_FILE")
    
    # Zgłoszenie nowego użytkownika
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $nick Zalogował/a się." >> "$CHAT_FILE"

    while true; do
        clear
        header "MENU"
        ascii_menu  # Wywołanie ASCII art menu
        echo -e "${cyan}=== Anonymous Chat ===${reset}"

        # Wskazanie, że użytkownik pisze
        if [ -z "$message" ]; then
            echo -e "${yellow}$nick pisze...${reset}"  # Informacja o tym, że użytkownik pisze
        fi

        echo -e "${yellow}Aby wyjść, wpisz: exit${reset}"
        echo -e "${yellow}Aby wysłać multimedia, wpisz: send [ścieżka do pliku]${reset}"
        echo -e "\n--- Ostatnie wiadomości ---"
        tail -n 10 "$CHAT_FILE" 2>/dev/null
        echo -e "\n--------------------------------"
        
        read -p "$nick: " message
        if [[ "$message" == "exit" ]]; then
            break
        elif [[ "$message" =~ ^send\ (.+)$ ]]; then
            file_path="${BASH_REMATCH[1]}"
            if [[ -f "$file_path" ]]; then
                # Zapisanie wiadomości z plikiem
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] $nick ==> Wysłano multimedia: $file_path" >> "$CHAT_FILE"
                echo -e "${green}Wysłano multimedia: $file_path${reset}"
            else
                echo -e "${red}Plik nie istnieje!${reset}"
            fi
        elif [[ -n "$message" ]]; then
            # Dodanie wiadomości użytkownika do czatu
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $nick ==> $message" >> "$CHAT_FILE"
            message=""  # Resetowanie zmiennej message po wysłaniu wiadomości
        fi
    done
}

# Menu główne
main_menu() {
    while true; do
        clear
        header "MENU"
        ascii_menu  # Wywołanie ASCII art menu
        echo -e "${cyan}=== Anonymous Chat ===${reset}"
        echo -e "${green}╔══════════════════════════════╗"
        echo -e "${green}║       Anonymous Tools       ║"
        echo -e "${green}╠══════════════════════════════╣"
        echo -e "${cyan}1) 💬 Anonymous Chat${reset}"
        echo -e "${red}2) 🚪 Wyloguj się${reset}"
        echo -e "${green}╚══════════════════════════════╝"
        read -p "Wybierz opcję: " choice
        
        case $choice in
            1) send_message ;;
            2) rm -f "$USER_FILE"; start_menu ;;
            *) echo -e "${red}Niepoprawna opcja!${reset}" ;;
        esac
        sleep 2
    done
}

# Funkcja startowa (wybór logowania lub rejestracji)
start_menu() {
    while true; do
        clear
        header "MENU"
        echo -e "${cyan}=== Witaj w Anonymous.sh ===${reset}"
        ascii_menu  # Wywołanie ASCII art menu
        echo -e "${green}1) 🔑 Zaloguj się${reset}"
        echo -e "${cyan}2) 📝 Zarejestruj nowe konto${reset}"
        echo -e "${red}3) ❌ Wyjście${reset}"
        read -p "Wybierz opcję: " choice
        
        case $choice in
            1) login; main_menu ;;
            2) register ;;
            3) exit 0 ;;
            *) echo -e "${red}Niepoprawny wybór!${reset}" ;;
        esac
    done
}

# Uruchamianie skryptu
animate
start_menu
