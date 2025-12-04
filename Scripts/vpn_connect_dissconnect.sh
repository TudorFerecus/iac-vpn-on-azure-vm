#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE=$1
ACTION=$2

usage() {
    echo -e "${YELLOW}Usage:${NC} $0 <config_file.conf> <connect|disconnect>"
    echo -e "Example: $0 ./vpn_configs/laptop.conf connect"
    exit 1
}

if [ -z "$CONFIG_FILE" ] || [ -z "$ACTION" ]; then
    usage
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}[ERROR]${NC} File '$CONFIG_FILE' not found!"
    exit 1
fi

case "$ACTION" in
    connect)
        echo -e "${GREEN}[INFO]${NC} Starting VPN connection using $CONFIG_FILE..."
        sudo wg-quick up "$CONFIG_FILE"
        
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}✔ Successfully connected!${NC}"
            echo -e "You can check your IP with: ${YELLOW}curl ifconfig.me${NC}"
        else
            echo -e "\n${RED}✘ Error connecting.${NC} Check the logs above."
        fi
        ;;
        
    disconnect)
        echo -e "${GREEN}[INFO]${NC} Disconnecting VPN..."
        sudo wg-quick down "$CONFIG_FILE"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✔ Successfully disconnected.${NC}"
        else
            echo -e "${RED}✘ Error disconnecting.${NC} Maybe it wasn't running?"
        fi
        ;;
        
    *)
        echo -e "${RED}[ERROR]${NC} Invalid action: '$ACTION'"
        echo -e "Use 'connect' or 'disconnect'."
        exit 1
        ;;
esac