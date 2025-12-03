#!/bin/bash

lab_name="OTLab12"
compose_file="${lab_name}.yml"

# Containers
## Shared L2 domain
single1_name="single-pc1"
single2_name="single-pc2"
single3_name="single-pc3"

## Ring topology
ring1_name="ring-node1"
ring2_name="ring-node2"
ring3_name="ring-node3"
ring4_name="ring-node4"
ring5_name="ring-node5"

## Star topology
star_core_name="star-core"
star1_name="star-leaf1"
star2_name="star-leaf2"
star3_name="star-leaf3"

# Images
parrot_image="ews-image-parrot04"
ubuntu_image="ews-image-ubuntu04"

# Networks
## Single-segment Ethernet
single_net="single-net" # 172.30.20.0/24

## Ring
ring_net_ab="ring-ab" # 172.30.40.0/29   (ring-node1 <-> ring-node2)
ring_net_bc="ring-bc" # 172.30.40.8/29   (ring-node2 <-> ring-node3)
ring_net_cd="ring-cd" # 172.30.40.16/29  (ring-node3 <-> ring-node4)
ring_net_de="ring-de" # 172.30.40.24/29  (ring-node4 <-> ring-node5)
ring_net_ea="ring-ea" # 172.30.40.32/29  (ring-node5 <-> ring-node1)

## Star
star_net_a="star-net-a" # 172.30.30.0/29
star_net_b="star-net-b" # 172.30.30.8/29
star_net_c="star-net-c" # 172.30.30.16/29

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  12-Fundamental Network Topologies\n"
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
  # ----------------------------------------
  # Single-segment Ethernet
  # ----------------------------------------
  $single1_name:
    image: $base_image
    container_name: $single1_name
    hostname: $single1_name
    mac_address: 02:12:20:00:00:01
    entrypoint: []
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $single_net:
        ipv4_address: 172.30.20.10

  $single2_name:
    image: $base_image
    container_name: $single2_name
    hostname: $single2_name
    mac_address: 02:12:20:00:00:02
    entrypoint: []
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $single_net:
        ipv4_address: 172.30.20.11

  $single3_name:
    image: $base_image
    container_name: $single3_name
    hostname: $single3_name
    mac_address: 02:12:20:00:00:03
    entrypoint: []
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $single_net:
        ipv4_address: 172.30.20.12
  
  # ----------------------------------------
  # Ring
  # ----------------------------------------
  $ring1_name:
    image: $base_image
    container_name: $ring1_name
    hostname: $ring1_name
    mac_address: 02:14:40:00:00:01
    entrypoint: []
    command: bash -c "ip route add 172.30.40.8/29 via 172.30.40.3 && \
                      ip route add 172.30.40.16/29 via 172.30.40.3 && \
                      ip route add 172.30.40.24/29 via 172.30.40.3 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    sysctls:
      net.ipv4.ip_forward: "1"
    networks:
      $ring_net_ab:
        ipv4_address: 172.30.40.2
      $ring_net_ea:
        ipv4_address: 172.30.40.34
  
  $ring2_name:
    image: $base_image
    container_name: $ring2_name
    hostname: $ring2_name
    mac_address: 02:14:40:00:00:02
    entrypoint: []
    command: bash -c "ip route add 172.30.40.16/29 via 172.30.40.11 && \
                      ip route add 172.30.40.24/29 via 172.30.40.11 && \
                      ip route add 172.30.40.32/29 via 172.30.40.11 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    sysctls:
      net.ipv4.ip_forward: "1"
    networks:
      $ring_net_ab:
        ipv4_address: 172.30.40.3
      $ring_net_bc:
        ipv4_address: 172.30.40.10

  $ring3_name:
    image: $base_image
    container_name: $ring3_name
    hostname: $ring3_name
    mac_address: 02:14:40:00:00:03
    entrypoint: []
    command: bash -c "ip route add 172.30.40.24/29 via 172.30.40.19 && \
                      ip route add 172.30.40.32/29 via 172.30.40.19 && \
                      ip route add 172.30.40.0/29 via 172.30.40.19 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    sysctls:
      net.ipv4.ip_forward: "1"
    networks:
      $ring_net_bc:
        ipv4_address: 172.30.40.11
      $ring_net_cd:
        ipv4_address: 172.30.40.18

  $ring4_name:
    image: $base_image
    container_name: $ring4_name
    hostname: $ring4_name
    mac_address: 02:14:40:00:00:04
    entrypoint: []
    command: bash -c "ip route add 172.30.40.32/29 via 172.30.40.27 && \
                      ip route add 172.30.40.0/29 via 172.30.40.27 && \
                      ip route add 172.30.40.8/29 via 172.30.40.27 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    sysctls:
      net.ipv4.ip_forward: "1"
    networks:
      $ring_net_cd:
        ipv4_address: 172.30.40.19
      $ring_net_de:
        ipv4_address: 172.30.40.26

  $ring5_name:
    image: $base_image
    container_name: $ring5_name
    hostname: $ring5_name
    mac_address: 02:14:40:00:00:05
    entrypoint: []
    command: bash -c "ip route add 172.30.40.0/29 via 172.30.40.34 && \
                      ip route add 172.30.40.8/29 via 172.30.40.34 && \
                      ip route add 172.30.40.16/29 via 172.30.40.34 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    sysctls:
      net.ipv4.ip_forward: "1"
    networks:
      $ring_net_de:
        ipv4_address: 172.30.40.27
      $ring_net_ea:
        ipv4_address: 172.30.40.35
  
  # ----------------------------------------
  # Star
  # ----------------------------------------
  $star_core_name:
    image: $base_image
    container_name: $star_core_name
    hostname: $star_core_name
    mac_address: 02:13:30:00:00:00
    entrypoint: []
    cap_add:
      - NET_ADMIN
      - NET_RAW
    sysctls:
      net.ipv4.ip_forward: "1"
    networks:
      $star_net_a:
        ipv4_address: 172.30.30.2
      $star_net_b:
        ipv4_address: 172.30.30.10
      $star_net_c:
        ipv4_address: 172.30.30.18

  $star1_name:
    image: $base_image
    container_name: $star1_name
    hostname: $star1_name
    mac_address: 02:13:30:00:00:01
    entrypoint: []
    command: bash -c "ip route replace  default via 172.30.30.2 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $star_net_a:
        ipv4_address: 172.30.30.3

  $star2_name:
    image: $base_image
    container_name: $star2_name
    hostname: $star2_name
    mac_address: 02:13:30:00:00:02
    entrypoint: []
    command: bash -c "ip route replace  default via 172.30.30.10 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $star_net_b:
        ipv4_address: 172.30.30.11

  $star3_name:
    image: $base_image
    container_name: $star3_name
    hostname: $star3_name
    mac_address: 02:13:30:00:00:03
    entrypoint: []
    command: bash -c "ip route replace  default via 172.30.30.18 && \
                      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $star_net_c:
        ipv4_address: 172.30.30.19

networks:
  $single_net:
    name: $single_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.20.0/24

  $ring_net_ab:
    name: $ring_net_ab
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.40.0/29

  $ring_net_bc:
    name: $ring_net_bc
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.40.8/29

  $ring_net_cd:
    name: $ring_net_cd
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.40.16/29

  $ring_net_de:
    name: $ring_net_de
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.40.24/29

  $ring_net_ea:
    name: $ring_net_ea
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.40.32/29

  $star_net_a:
    name: $star_net_a
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.30.0/29

  $star_net_b:
    name: $star_net_b
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.30.8/29

  $star_net_c:
    name: $star_net_c
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.30.16/29
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

        if [[ "$distro" == "parrot" ]]; then
            selected_image="$parrot_image"
        elif [[ "$distro" == "ubuntu" ]]; then
            selected_image="$ubuntu_image"
        else
            printf "\033[31m[Error]\033[0m Invalid distro. Please use 'parrot' or 'ubuntu'.\n"
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
        if container_exists "$single1_name" || container_exists "$single2_name" || container_exists "$single3_name" || \
           container_exists "$ring1_name" || container_exists "$ring2_name" || container_exists "$ring3_name" || \
           container_exists "$ring4_name" || container_exists "$ring5_name" || \
           container_exists "$star_core_name" || container_exists "$star1_name" || container_exists "$star2_name" || container_exists "$star3_name"; then
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
        docker network rm "$single_net" "$ring_net_ab" "$ring_net_bc" "$ring_net_cd" "$ring_net_de" "$ring_net_ea" "$star_net_a" "$star_net_b" "$star_net_c" 2>/dev/null
        rm -f "$compose_file"
        printf "\033[32m✔ All $lab_name resources removed.\033[0m\n"
        ;;
    -run)
        show_banner
        # Standard: single-pc1
        target="${2:-single1}"
        case "$target" in
            single1) target_name="$single1_name" ;;
            single2) target_name="$single2_name" ;;
            single3) target_name="$single3_name" ;;
            ring1) target_name="$ring1_name" ;;
            ring2) target_name="$ring2_name" ;;
            ring3) target_name="$ring3_name" ;;
            ring4) target_name="$ring4_name" ;;
            ring5) target_name="$ring5_name" ;;
            star-core) target_name="$star_core_name" ;;
            star1) target_name="$star1_name" ;;
            star2) target_name="$star2_name" ;;
            star3) target_name="$star3_name" ;;
            *)
                printf "\033[31m[Error]\033[0m Invalid target. Use one of: single1|single2|single3|ring1|ring2|ring3|ring4|ring5|star-core|star1|star2|star3\n"
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
        echo "Usage: $0 -start [parrot|ubuntu] | -stop | -clean | -run [target] | -restart | -status"
        echo ""
        echo "  -start     Start the $lab_name environment using the specified distro (default: ubuntu)"
        echo "             Valid options: parrotsec (core) or ubuntu (22.04)"
        echo "  -run       Open a terminal inside one container"
        echo "             Targets: single1|single2|single3|ring1|ring2|ring3|ring4|ring5|star-core|star1|star2|star3"
        echo "  -clean     Remove containers, volumes, and networks"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        echo "  -status    Show current containers status"
        echo ""
        echo "[i] Local images required: ews-image-parrot04 and ews-image-ubuntu04"
        exit 1
        ;;
esac