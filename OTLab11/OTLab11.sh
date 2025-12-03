#!/bin/bash

lab_name="OTLab11"
compose_file="${lab_name}.yml"

# Containers
victim_name="user-browser"
proxy_name="phishing-proxy"
legit_name="legit-hmi"
attacker_name="attacker"

# Images
attacker_image="ubuntu:22.04"

# Networks
flat_net="corp-net" # 172.30.0.0/24
ot_net="ot_net" # 172.30.10.0/26

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  11-AiTM MFA Bypass\n"
    printf "Version:   1.0\n"
    printf "Author:    substationworm\n"
    printf "Contact:   in/lffreitas-gutierres\n"
    printf "\033[0m" # Reset all styles
    echo ""
}

# ----------------------------------------
# Function to generate Docker Compose file
generate_compose_file() {
cat > "$compose_file" <<EOF
services:
  $victim_name:
    build: ./UserBrowser
    container_name: $victim_name
    hostname: $victim_name
    networks:
      $flat_net:
        ipv4_address: 172.30.0.10
    extra_hosts:
      - "phishing.test:172.30.0.20"
    command: bash -c "tail -f /dev/null"
  
  $proxy_name:
    build: ./PhishingProxy
    container_name: $proxy_name
    hostname: $proxy_name
    volumes:
      - loot:/loot
    networks:
      $flat_net:
        ipv4_address: 172.30.0.20
      $ot_net:
        ipv4_address: 172.30.10.20
    depends_on:
      - $legit_name
    ports:
      - "8081:80"
  
  $legit_name:
    build: ./LegitHMI
    container_name: $legit_name
    hostname: $legit_name
    networks:
      $ot_net:
        ipv4_address: 172.30.10.40
    environment:
      - FLASK_SECRET=otlab-secret
    ports:
      - "8000:8000"
  
  $attacker_name:
    image: $attacker_image
    container_name: $attacker_name
    hostname: $attacker_name
    networks:
      $flat_net:
        ipv4_address: 172.30.0.30
      $ot_net:
        ipv4_address: 172.30.10.30
    extra_hosts:
      - "phishing.test:172.30.0.20"
      - "legit.test:172.30.10.40"
    volumes:
      - loot:/loot
    stdin_open: true
    tty: true
    command: bash -c "apt update && apt install -y curl && tail -f /dev/null"

networks:
  $flat_net:
    name: $flat_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/24
  $ot_net:
    name: $ot_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.10.0/26

volumes:
  loot:
    name: otlab-loot
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
        check_requirements
        printf "\033[1;33m[Working]\033[0m Starting $lab_name. . .\n"
        generate_compose_file
        $DOCKER_COMPOSE_CMD -f "$compose_file" up -d --build
        if [ $? -eq 0 ]; then
            printf "\033[32m✔ $lab_name started.\033[0m\n"
        else
            printf "\033[31m✘ $lab_name failed to start.\033[0m\n"
            exit 1
        fi
        ;;
    -stop)
        show_banner
        if container_exists "$victim_name" || container_exists "$proxy_name" || \
           container_exists "$legit_name" || container_exists "$attacker_name"; then
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
        docker network rm "$flat_net" "$ot_net" 2>/dev/null
        rm -f "$compose_file"
        printf "\033[32m✔ All $lab_name resources removed.\033[0m\n"
        ;;
    -run)
        show_banner
        # Standard: user
        target="${2:-user}"
        case "$target" in
            user) target_name="$victim_name" ;;
            proxy) target_name="$proxy_name" ;;
            hmi) target_name="$legit_name" ;;
            attacker) target_name="$attacker_name" ;;
            *)
                printf "\033[31m[Error]\033[0m Invalid target. Use one of: user|proxy|hmi|attacker\n"
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
        echo "Usage: $0 -start | -stop | -clean | -run [user|proxy|hmi|attacker] | -restart | -status"
        echo ""
        echo "  -start     Start the $lab_name environment"
        echo "  -run       Open a terminal inside one container (user|proxy|hmi|attacker)"
        echo "  -clean     Remove containers, volumes, and networks"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        echo "  -status    Show current containers status"
        exit 1
        ;;
esac