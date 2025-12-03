#!/bin/bash
set -e

LAB_NAME="OTLab11"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

USERBROWSER_DIR="$BASE_DIR/UserBrowser"
PROXY_DIR="$BASE_DIR/PhishingProxy"
HMI_DIR="$BASE_DIR/LegitHMI"

echo "[+] Setting up offline Docker images for $LAB_NAME..."

# UserBrowser
if [ -d "$USERBROWSER_DIR" ]; then
    echo "[+] Building image: ews-image-otlab11-user-browser"
    docker build -t ews-image-otlab11-user-browser "$USERBROWSER_DIR"
else
    echo "[!] Warning: UserBrowser directory not found at $USERBROWSER_DIR"
fi

# PhishingProxy
if [ -d "$PROXY_DIR" ]; then
    echo "[+] Building image: ews-image-otlab11-proxy"
    docker build -t ews-image-otlab11-proxy "$PROXY_DIR"
else
    echo "[!] Warning: PhishingProxy directory not found at $PROXY_DIR"
fi

# LegitHMI
if [ -d "$HMI_DIR" ]; then
    echo "[+] Building image: ews-image-otlab11-legit-hmi"
    docker build -t ews-image-otlab11-legit-hmi "$HMI_DIR"
else
    echo "[!] Warning: LegitHMI directory not found at $HMI_DIR"
fi

echo "[+] Skipping attacker image: it is expected to be pre-built from previous exercises."

echo "[i] All required offline images for $LAB_NAME have been built successfully."