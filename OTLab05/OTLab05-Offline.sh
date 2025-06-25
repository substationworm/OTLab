#!/bin/bash

lab_name="OTLab05"
compose_file="${lab_name}.yml"

ot_container_name01="plc01-slave"
ot_container_name02="plc02-master"
ews_container_name="otlab-student"
ubuntu_image="ews-image-ubuntu01"
kali_image="ews-image-kali01"

lab_net01="plc01-net"
lab_net02="plc02-net"

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  05-Modbus/TCP Routing Between Subnets\n"
    printf "Version:   1.0-Offline\n"
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
  $ot_container_name01:
    image: $ubuntu_image
    container_name: $ot_container_name01
    hostname: $ot_container_name01
    mac_address: 38:31:AC:00:01:01
    networks:
      $lab_net01:
        ipv4_address: 192.168.11.101
    cap_add:
      - NET_ADMIN
      - NET_RAW
    privileged: true
    command: >
      bash -c '
        ip route add 192.168.12.0/24 via 192.168.11.200 &&
        printf "%s\n" \
"from pymodbus.server import StartTcpServer" \
"from pymodbus.datastore import ModbusSlaveContext, ModbusServerContext, ModbusSequentialDataBlock" \
"store = ModbusSlaveContext(hr=ModbusSequentialDataBlock(0, [0]*200))" \
"context = ModbusServerContext(slaves=store, single=True)" \
"StartTcpServer(context, address=(\\"0.0.0.0\\", 502))" \
> /server.py &&
        python3 /server.py'
    ports:
      - "502:502"

  $ot_container_name02:
    image: $ubuntu_image
    container_name: $ot_container_name02
    hostname: $ot_container_name02
    mac_address: 38:31:AC:00:01:02
    networks:
      $lab_net02:
        ipv4_address: 192.168.12.102
    cap_add:
      - NET_ADMIN
      - NET_RAW
    privileged: true
    command: >
      bash -c '
        ip route replace default via 192.168.12.200 &&
        printf "%s\n" \
"from pymodbus.client import ModbusTcpClient" \
"import time" \
"while True:" \
"    client = ModbusTcpClient(\\"192.168.11.101\\", port=502)" \
"    print(\\"[CLIENT] Connecting to 192.168.11.101:502\\")" \
"    result = client.write_registers(100, [75,72,79,79,82])" \
"    print(\\"[CLIENT] Response: {}\\".format(result))" \
"    client.close()" \
"    time.sleep(10)" \
> /client.py &&
        echo "[CLIENT] Waiting for Modbus server. . ." &&
        until nc -z 192.168.11.101 502; do sleep 2; done &&
        echo "[CLIENT] Server is up. Starting client loop. . ." &&
        sleep 2 &&
        python3 /client.py'

  $ews_container_name:
    image: $ews_image
    container_name: $ews_container_name
    hostname: $ews_container_name
    command: >
      bash -c '
        sysctl -w net.ipv4.ip_forward=1 &&
        tail -f /dev/null'
    networks:
      $lab_net01:
        ipv4_address: 192.168.11.200
      $lab_net02:
        ipv4_address: 192.168.12.200
    privileged: true

networks:
  $lab_net01:
    name: $lab_net01
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.11.0/24

  $lab_net02:
    name: $lab_net02
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