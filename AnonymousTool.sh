#!/bin/bash

# Adres serwera (zmień na adres swojego VPS, jeśli chcesz działać globalnie)
SERVER_URL="http://127.0.0.1:5000"

# Sprawdzenie, czy Python jest zainstalowany
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 nie jest zainstalowany! Zainstaluj go i spróbuj ponownie."
    exit 1
fi

# Uruchomienie serwera w tle
start_server() {
    echo "🔄 Uruchamiam serwer czatu..."
    python3 - <<EOF &
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

messages = []
active_users = set()

@app.route('/send', methods=['POST'])
def send_message():
    data = request.json
    if 'nick' in data and 'message' in data:
        messages.append(f"{data['nick']}: {data['message']}")
        return jsonify({"status": "OK"})
    return jsonify({"status": "ERROR"}), 400

@app.route('/messages', methods=['GET'])
def get_messages():
    return jsonify(messages)

@app.route('/active_users', methods=['POST'])
def add_user():
    data = request.json
    if 'nick' in data:
        active_users.add(data['nick'])
        return jsonify({"status": "OK"})
    return jsonify({"status": "ERROR"}), 400

@app.route('/users', methods=['GET'])
def get_users():
    return jsonify(list(active_users))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF
}

# Sprawdzenie, czy serwer działa, jeśli nie – uruchom go
if ! curl -s "$SERVER_URL/messages" >/dev/null; then
    start_server
    sleep 3  # Czekamy, aż serwer się uruchomi
fi

# Pobranie nicku użytkownika
read -p "Podaj swój nick: " nick

# Rejestracja użytkownika na serwerze
curl -s -X POST -H "Content-Type: application/json" -d "{\"nick\": \"$nick\"}" "$SERVER_URL/active_users" >/dev/null

# Funkcja wyświetlająca wiadomości na żywo
fetch_messages() {
    while true; do
        clear
        echo "🔵 Anonymous Chat - Online"
        echo "----------------------------------"
        
        # Pobranie wiadomości z serwera
        curl -s "$SERVER_URL/messages" | jq -r '.[]'
        
        # Pobranie aktywnych użytkowników
        echo -e "\n👥 Aktywni użytkownicy:"
        curl -s "$SERVER_URL/users" | jq -r '.[]'

        sleep 2  # Aktualizacja co 2 sekundy
    done
}

# Uruchomienie pobierania wiadomości w tle
fetch_messages &

# Wysyłanie wiadomości
while true; do
    read -p "$nick: " message
    if [[ "$message" == "exit" ]]; then
        echo "❌ Wylogowywanie..."
        kill %1  # Zatrzymaj pobieranie wiadomości
        exit 0
    fi

    curl -s -X POST -H "Content-Type: application/json" -d "{\"nick\": \"$nick\", \"message\": \"$message\"}" "$SERVER_URL/send" >/dev/null
done
