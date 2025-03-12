#!/bin/bash

# Kolory terminala
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
cyan='\033[1;36m'
reset='\033[0m'

CHAT_FILE="chat.txt"
USER_FILE="user_info.txt"
USER_DB="users.txt"
ACTIVE_USERS="active_users.txt"

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

# Funkcja wyświetlania nagłówka
header() {
    clear
    echo -e "${purple}╔═════════════════════════════════╗"
    echo -e "║      ${white}$1${purple}        ║"
    echo -e "╚═════════════════════════════════╝${reset}"
}

# Rejestracja użytkownika
register() {
    header "Rejestracja"

    read -p "Podaj email: " email
    if grep -q "^$email|" "$USER_DB"; then
        echo -e "${red}Konto z tym emailem już istnieje!${reset}"
        sleep 2
        return
    fi

    read -sp "Podaj hasło: " password
    echo ""
    read -p "Wybierz nick: " nick

    echo "$email|$password|$nick" >> "$USER_DB"
    echo -e "${green}Konto utworzone! Możesz się teraz zalogować.${reset}"
    sleep 2
}

# Logowanie użytkownika
login() {
    header "Logowanie"

    while true; do
        read -p "Email: " email
        read -sp "Hasło: " password
        echo ""

        if grep -q "^$email|$password|" "$USER_DB"; then
            nick=$(grep "^$email|$password|" "$USER_DB" | cut -d '|' -f3)
            echo "$nick" > "$USER_FILE"

            # Dodanie użytkownika do listy aktywnych
            if ! grep -q "^$nick$" "$ACTIVE_USERS"; then
                echo "$nick" >> "$ACTIVE_USERS"
            fi

            echo -e "${green}Zalogowano jako $nick!${reset}"
            sleep 2
            break
        else
            echo -e "${red}Nieprawidłowy email lub hasło!${reset}"
            sleep 2
        fi
    done
}

# Wylogowanie użytkownika
logout() {
    if [ -f "$USER_FILE" ]; then
        nick=$(cat "$USER_FILE")
        sed -i "/^$nick$/d" "$ACTIVE_USERS"
        rm -f "$USER_FILE"
    fi
}

# Wyświetlanie aktywnych użytkowników
show_active_users() {
    echo -e "\n${yellow}👥 Aktywni użytkownicy:${reset}"
    if [ -s "$ACTIVE_USERS" ]; then
        cat "$ACTIVE_USERS"
    else
        echo "Brak aktywnych użytkowników."
    fi
}

# Funkcja czatu na żywo
chat() {
    nick=$(cat "$USER_FILE")
    echo "[$(date '+%H:%M:%S')] $nick dołączył/a do czatu." >> "$CHAT_FILE"

    # Uruchamianie procesu odświeżania czatu w tle
    tail -f "$CHAT_FILE" &  # Proces działa w tle
    TAIL_PID=$!  # Pobieramy PID procesu, aby go później zakończyć

    while true; do
        echo -e "\n${yellow}Aby wyjść, wpisz: exit${reset}"
        read -p "$nick: " message

        if [[ "$message" == "exit" ]]; then
            kill $TAIL_PID  # Zatrzymanie procesu odświeżania czatu
            logout
            break
        elif [[ -n "$message" ]]; then
            echo "[$(date '+%H:%M:%S')] $nick: $message" >> "$CHAT_FILE"
        fi
    done
}

# Główne menu
main_menu() {
    while true; do
        clear
        header "Anonymous Chat"
        echo -e "1) 🔑 Zaloguj się"
        echo -e "2) 📝 Zarejestruj nowe konto"
        echo -e "3) ❌ Wyjście"
        read -p "Wybierz opcję: " choice
        
        case $choice in
            1) login; chat ;;
            2) register ;;
            3) logout; exit 0 ;;
            *) echo -e "${red}Niepoprawna opcja!${reset}" ;;
        esac
    done
}

# Uruchomienie programu
animate
main_menu
