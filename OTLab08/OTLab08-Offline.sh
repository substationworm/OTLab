#!/bin/bash

lab_name="OTLab08"
compose_file="${lab_name}.yml"

# Containers (generic corporate hosts)
pc1_name="corp-pc1" # Flat net
pc2_name="corp-pc2" # Flat net
pc3_name="corp-pc3" # Flat net
pc4_name="corp-pc4" # Segmented net A
pc5_name="corp-pc5" # Segmented net B
pc6_name="corp-pc6" # Segmented net C

# Images
kali_image="ews-image-kali03"
ubuntu_image="ews-image-ubuntu03"

# Networks
## Flat
### Single /24 broadcast domain with three hosts
flat_net="corp-net" # 172.30.0.0/24

## Segmented
### Three /26 subnets (each with one host)
seg_net_a="corp-net-a" # 172.30.10.0/26
seg_net_b="corp-net-b" # 172.30.10.64/26
seg_net_c="corp-net-c" # 172.30.10.128/26

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  08-Subnet Masks and Segmentation\n"
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
    image: $base_image
    container_name: $pc1_name
    hostname: $pc1_name
    mac_address: 02:11:22:33:44:01
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $flat_net:
        ipv4_address: 172.30.0.10

  $pc2_name:
    image: $base_image
    container_name: $pc2_name
    hostname: $pc2_name
    mac_address: 02:11:22:33:44:02
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $flat_net:
        ipv4_address: 172.30.0.11

  $pc3_name:
    image: $base_image
    container_name: $pc3_name
    hostname: $pc3_name
    mac_address: 02:11:22:33:44:03
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $flat_net:
        ipv4_address: 172.30.0.12

  $pc4_name:
    image: $base_image
    container_name: $pc4_name
    hostname: $pc4_name
    mac_address: 02:11:22:33:44:11
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $seg_net_a:
        ipv4_address: 172.30.10.10

  $pc5_name:
    image: $base_image
    container_name: $pc5_name
    hostname: $pc5_name
    mac_address: 02:11:22:33:44:12
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $seg_net_b:
        ipv4_address: 172.30.10.74

  $pc6_name:
    image: $base_image
    container_name: $pc6_name
    hostname: $pc6_name
    mac_address: 02:11:22:33:44:13
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $seg_net_c:
        ipv4_address: 172.30.10.130

networks:
  $flat_net:
    name: $flat_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/24
  $seg_net_a:
    name: $seg_net_a
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.10.0/26
  $seg_net_b:
    name: $seg_net_b
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.10.64/26
  $seg_net_c:
    name: $seg_net_c
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.10.128/26
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
        if container_exists "$pc1_name" || container_exists "$pc2_name" || container_exists "$pc3_name" || \
           container_exists "$pc4_name" || container_exists "$pc5_name" || container_exists "$pc6_name"; then
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
        docker network rm "$flat_net" "$seg_net_a" "$seg_net_b" "$seg_net_c" 2>/dev/null
        rm -f "$compose_file"
        printf "\033[32m✔ All $lab_name resources removed.\033[0m\n"
        ;;
    -run)
        show_banner
        # Standard: pc1
        target="${2:-pc1}"
        case "$target" in
            pc1) target_name="$pc1_name" ;;
            pc2) target_name="$pc2_name" ;;
            pc3) target_name="$pc3_name" ;;
            pc4) target_name="$pc4_name" ;;
            pc5) target_name="$pc5_name" ;;
            pc6) target_name="$pc6_name" ;;
            *)
                printf "\033[31m[Error]\033[0m Invalid target. Use one of: pc1|pc2|pc3|pc4|pc5|pc6\n"
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
        echo "Usage: $0 -start [kali|ubuntu] | -stop | -clean | -run [pc1|pc2|pc3|pc4|pc5|pc6] | -restart | -status"
        echo ""
        echo "  -start     Start the $lab_name environment using the specified distro (default: ubuntu)"
        echo "             Valid options: kali (rolling) or ubuntu (22.04)"
        echo "  -run       Open a terminal inside one container (pc1|pc2|pc3|pc4|pc5|pc6)"
        echo "  -clean     Remove containers, volumes, and networks"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        echo "  -status    Show current containers status"
        echo ""
        echo "[i] Local images required: ews-image-kali03 and ews-image-ubuntu03"
        exit 1
        ;;
esac