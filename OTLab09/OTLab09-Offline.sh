#!/bin/bash

lab_name="OTLab09"
compose_file="${lab_name}.yml"

# Containers (generic corporate hosts)
v1_name="server1"
v2_name="server2"
v3_name="server3"
attacker_name="attacker"

# Images
kali_image="ews-image-kali01"
ubuntu_image="ews-image-ubuntu01"
server1_image="ews-image-server01"
server2_image="ews-image-server02"
server3_image="ews-image-server03"

# Networks
## Flat
### Single /24 broadcast domain
flat_net="corp-net" # 172.30.0.0/24

## Segmented
### One /26 subnet
seg_net="corp-subnet" # 172.30.10.0/26

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  09-Scanning Techniques with 'nmap'\n"
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
  $v1_name:
    image: $server1_image
    container_name: $v1_name
    hostname: $v1_name
    mac_address: 02:aa:bb:cc:dd:11
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $flat_net:
        ipv4_address: 172.30.0.11
    volumes:
        - ./logs/server1:/var/log/otlab

  $v2_name:
    image: $server2_image
    container_name: $v2_name
    hostname: $v2_name
    mac_address: 02:aa:bb:cc:dd:12
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $flat_net:
        ipv4_address: 172.30.0.12
    volumes:
        - ./logs/server2:/var/log/otlab

  $v3_name:
    image: $server3_image
    container_name: $v3_name
    hostname: $v3_name
    mac_address: 02:aa:bb:cc:dd:13
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $seg_net:
        ipv4_address: 172.30.10.10
    volumes:
        - ./logs/server3:/var/log/otlab

  $attacker_name:
    image: $base_image
    container_name: $attacker_name
    hostname: $attacker_name
    mac_address: 02:aa:bb:cc:dd:01
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $flat_net:
        ipv4_address: 172.30.0.5
      $seg_net:
        ipv4_address: 172.30.10.5

networks:
  $flat_net:
    name: $flat_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/24
  $seg_net:
    name: $seg_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.10.0/26
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
        if container_exists "$v1_name" || container_exists "$v2_name" || container_exists "$v3_name" || \
           container_exists "$attacker_name"; then
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
        docker network rm "$flat_net" "$seg_net" 2>/dev/null
        rm -f "$compose_file"
        printf "\033[32m✔ All $lab_name resources removed.\033[0m\n"
        ;;
    -run)
        show_banner
        # Standard: attacker
        target="${2:-attacker}"
        case "$target" in
            attacker) target_name="$attacker_name" ;;
            server1) target_name="$v1_name" ;;
            server2) target_name="$v2_name" ;;
            server3) target_name="$v3_name" ;;
            *)
                printf "\033[31m[Error]\033[0m Invalid target. Use one of: attacker|server1|server2|server3\n"
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
        echo "Usage: $0 -start [kali|ubuntu] | -stop | -clean | -run [attacker|server1|server2|server3] | -restart | -status"
        echo ""
        echo "  -start     Start the $lab_name environment using the specified distro for the attacker (default: ubuntu)"
        echo "             Valid options: kali (rolling) or ubuntu (22.04)"
        echo "  -run       Open a terminal inside one container (attacker|server1|server2|server3)"
        echo "  -clean     Remove containers, volumes, and networks"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        echo "  -status    Show current containers status"
        echo ""
        echo "[i] Local images required: ews-image-kali01, ews-image-ubuntu01, ews-image-server01, ews-image-server02, and ews-image-server03"
        exit 1
        ;;
esac