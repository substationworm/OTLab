#!/bin/bash

lab_name="OTLab07"
compose_file="${lab_name}.yml"

ot_container_name="plc-hmi"
ews_container_name="otlab-student"
ubuntu_image="ubuntu:22.04"
kali_image="kalilinux/kali-rolling"

lab_net="otlab-net"

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  07-Default Password Exposure\n"
    printf "Version:   1.0\n"
    printf "Author:    substationworm\n"
    printf "Contact:   in/lffreitas-gutierres\n"
    printf "\033[0m" # Reset all styles
    echo ""
}

# ----------------------------------------
# Function to generate Docker Compose file
generate_compose_file() {
    local ews_image="$1"
    
    cat > "$compose_file" <<EOF
services:
  $ot_container_name:
    image: honeynet/conpot:latest
    container_name: $ot_container_name
    hostname: $ot_container_name
    mac_address: 00:00:6C:0A:B0:C0
    networks:
      $lab_net:
        ipv4_address: 192.168.12.22
    cap_add:
      - NET_ADMIN
      - NET_RAW
    privileged: true
    command: >
      sh -c '
        echo "<!DOCTYPE html><html><head><title>PLC Login</title><script>function login() { var user = document.getElementById(\"user\").value; var pass = document.getElementById(\"pass\").value; if (user === \"admin\" && pass === \"password\") { document.body.innerHTML = \"<h1>System successfully unlocked:</h1><p>UFSM00741{Warning: Using default credentials}</p>\"; } else { alert(\"Access denied!\"); } }</script></head><body><h2>User Management and Access Control Panel</h2><input type=\\"text\\" id=\\"user\\" placeholder=\\"Username\\"><br><input type=\\"password\\" id=\\"pass\\" placeholder=\\"Password\\"><br><br><button onclick=\\"login()\\">Login</button></body></html>" > /home/conpot/.local/lib/python3.6/site-packages/conpot-0.6.0-py3.6.egg/conpot/templates/default/http/htdocs/index.html &&
        /home/conpot/.local/bin/conpot -f --template default
      '

  $ews_container_name:
    image: $ews_image
    container_name: $ews_container_name
    hostname: $ews_container_name
    command: >
      bash -c '
        apt update && apt install -y python2 git ca-certificates iputils-ping nmap net-tools netdiscover snmp tcpdump procps curl &&
        [ -d /opt/plcscan ] || git clone https://github.com/meeas/plcscan.git /opt/plcscan &&
        tail -f /dev/null
      '
    networks:
      $lab_net:
        ipv4_address: 192.168.12.200
    privileged: true

networks:
  $lab_net:
    name: $lab_net
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.12.0/24
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
    docker ps -a --format '{{.Names}}' | grep -q "$1"
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
        if container_exists "$ot_container_name01" || container_exists "$ot_container_name02" || container_exists "$ews_container_name"; then
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
        if container_exists "$ot_container_name01" || container_exists "$ot_container_name02" || container_exists "$ews_container_name"; then
            check_requirements
            printf "\033[1;33m[Working]\033[0m Cleaning up all $lab_name resources. . .\n"
            $DOCKER_COMPOSE_CMD -f "$compose_file" down -v
            docker network rm "$lab_net01" "$lab_net02" 2>/dev/null
            rm -f "$compose_file"
            printf "\033[32m✔ All $lab_name resources removed.\033[0m\n"
        else
             printf "\033[34m[Information]\033[0m No containers found to clean.\n"
             exit 1
        fi
        ;;
    -run)
        show_banner
        if container_exists "$ews_container_name"; then
            check_requirements
            printf "\033[1;33m[Working]\033[0m Accessing $ews_container_name terminal. . .\n"
            docker exec -it "$ews_container_name" bash
        else
            printf "\033[31m[Error]\033[0m Container $ews_container_name not found.\n"
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
    *)
        show_banner
        echo "Usage: $0 -start [kali|ubuntu] | -stop | -clean | -run | -restart"
        echo ""
        echo "  -start     Start the $lab_name environment using the specified distro (default: ubuntu)"
        echo "             Valid options: kali (rolling) or ubuntu (22.04)"
        echo "  -run       Open a terminal inside the $ews_container_name container"
        echo "  -clean     Remove containers, volumes, and network"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        exit 1
        ;;
esac