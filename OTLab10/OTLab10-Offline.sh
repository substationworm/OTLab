#!/bin/bash

lab_name="OTLab10"
compose_file="${lab_name}.yml"

# Containers
pc1_name="client"
pc2_name="server"
sniffer_name="sniffer"

# Images
kali_image="ews-image-kali04"
ubuntu_image="ews-image-ubuntu04"

# Network
net_name="otlab-net" # 172.31.0.0/24

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  10-TCP/IP and Three-Way Handshake\n"
    printf "Version:   1.0-Offline\n"
    printf "Author:    substationworm\n"
    printf "Contact:   in/lffreitas-gutierres\n"
    printf "\033[0m" # Reset all styles
    echo ""
}

# ----------------------------------------
# Function to generate Docker Compose file
generate_compose_file() {
    local base_image="$1"
    
    cat > "$compose_file" <<EOF
services:
  $pc1_name:
    image: $ubuntu_image
    container_name: $pc1_name
    hostname: $pc1_name
    mac_address: 02:21:22:33:44:01
    networks:
      $net_name:
        ipv4_address: 172.31.0.10
    cap_add:
      - NET_ADMIN

  $pc2_name:
    image: $ubuntu_image
    container_name: $pc2_name
    hostname: $pc2_name
    mac_address: 02:21:22:33:44:02
    networks:
      $net_name:
        ipv4_address: 172.31.0.11
    cap_add:
      - NET_ADMIN

  $sniffer_name:
    image: $base_image
    container_name: $sniffer_name
    hostname: $sniffer_name
    network_mode: host
    cap_add:
      - NET_ADMIN

networks:
  $net_name:
    name: $net_name
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.0.0/24
EOF
}

# ----------------------------------------
# System requirements check
check_requirements() {
    error_flag=0

    if ! command -v docker >/dev/null 2>&1; then
        printf "\033[31m[Error]\033[0m Docker is not installed on this system.\n"
        error_flag=1
    elif ! docker info >/dev/null 2>&1; then
        printf "\033[31m[Error]\033[0m Docker is installed, but not accessible.\n"
        error_flag=1
    fi

    if command -v docker-compose >/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="docker-compose"
    elif docker compose version >/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="docker compose"
    else
        printf "\033[31m[Error]\033[0m Docker Compose is not installed.\n"
        error_flag=1
    fi

    if [ "$error_flag" -eq 1 ]; then
        printf "\033[31m✘ The $lab_name system requirements check failed.\033[0m\n"
        exit 1
    fi
}

# ----------------------------------------
# Function to check if a container exists
container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "^$1$"
}

# ----------------------------------------
# Command handling
case "$1" in
    -start)
        show_banner
        distro="${2:-ubuntu}"

        if [[ "$distro" == "kali" ]]; then
            selected_image="$kali_image"
        elif [[ "$distro" == "ubuntu" ]]; then
            selected_image="$ubuntu_image"
        else
            printf "\033[31m[Error]\033[0m Invalid distro. Please use 'kali' or 'ubuntu'.\n"
            exit 1
        fi

        check_requirements
        printf "\033[1;33m[Working]\033[0m Starting $lab_name. . .\n"
        generate_compose_file "$selected_image"
        $DOCKER_COMPOSE_CMD -f "$compose_file" up -d
        if [ $? -eq 0 ]; then
            printf "\033[32m✔ $lab_name started.\033[0m\n"
        else
            printf "\033[31m✘ $lab_name failed to start.\033[0m\n"
            exit 1
        fi
        ;;
    -stop)
        show_banner
        if container_exists "$pc1_name" || container_exists "$pc2_name" || container_exists "$sniffer_name"; then
            check_requirements
            printf "\033[1;33m[Working]\033[0m Stopping $lab_name. . .\n"
            $DOCKER_COMPOSE_CMD -f "$compose_file" stop
            printf "\033[32m✔ $lab_name stopped.\033[0m\n"
        else
            printf "\033[34m[Information]\033[0m No containers to stop.\n"
            exit 1
        fi
        ;;
    -clean)
        show_banner
        check_requirements
        printf "\033[1;33m[Working]\033[0m Cleaning up all $lab_name resources. . .\n"
        $DOCKER_COMPOSE_CMD -f "$compose_file" down -v 2>/dev/null
        docker network rm "$net_name" 2>/dev/null
        rm -f "$compose_file"
        printf "\033[32m✔ All $lab_name resources removed.\033[0m\n"
        ;;
    -run)
        show_banner
        # Standard: client
        target="${2:-client}"
        case "$target" in
            client) target_name="$pc1_name" ;;
            server) target_name="$pc2_name" ;;
            sniffer) target_name="$sniffer_name" ;;
            *)
                printf "\033[31m[Error]\033[0m Invalid target. Use one of: client|server|sniffer\n"
                exit 1
                ;;
        esac

        if container_exists "$target_name"; then
            check_requirements
            printf "\033[1;33m[Working]\033[0m Accessing $target_name terminal. . .\n"
            docker exec -it "$target_name" bash
        else
            printf "\033[31m[Error]\033[0m Container $target_name not found.\n"
            exit 1
        fi
        ;;
    -restart)
        show_banner
        check_requirements
        if [ ! -f "$compose_file" ]; then
            printf "\033[31m[Error]\033[0m Cannot restart: $compose_file not found.\n"
            exit 1
        fi

        printf "\033[1;33m[Working]\033[0m Restarting $lab_name. . .\n"
        $DOCKER_COMPOSE_CMD -f "$compose_file" up -d
        if [ $? -eq 0 ]; then
            printf "\033[32m✔ $lab_name restarted.\033[0m\n"
        else
            printf "\033[31m✘ $lab_name failed to restart.\033[0m\n"
            exit 1
        fi
        ;;
    -status)
        show_banner
        check_requirements
        $DOCKER_COMPOSE_CMD -f "$compose_file" ps
        ;;
    *)
        show_banner
        echo "Usage: $0 -start [kali|ubuntu] | -stop | -clean | -run [client|server|sniffer] | -restart | -status"
        echo ""
        echo "  -start     Start the $lab_name environment using the specified distro for the sniffer (default: ubuntu)"
        echo "             Valid options: kali (rolling) or ubuntu (22.04)"
        echo "  -run       Open a terminal inside one container (client|server|sniffer)"
        echo "  -clean     Remove containers, volumes, and network"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        echo "  -status    Show current containers status"
        echo ""
        echo "[i] Local images required: ews-image-kali04 and ews-image-ubuntu04"
        exit 1
        ;;
esac