#!/bin/bash

lab_name="OTLab13"
compose_file="${lab_name}.yml"

# Containers (corporate workstations)
pc1_name="corp-pc1"
pc2_name="corp-pc2"
pc3_name="corp-pc3"
gw_name="corp-gw"

# Containers (DMZ)
jump_name="jump-host"
log_name="log-server"

# Containers (OT-ICS)
ot1_name="ot1"
ot2_name="ot2"
hmi_name="hmi"

# Images
parrot_image="parrotsec/core"
ubuntu_image="ubuntu:22.04"

# Networks
corp_net="corp-net" # 172.30.0.0/24
dmz_net="dmz-net"   # 172.30.10.0/27
ot_net="ot-net"     # 172.30.20.0/28

# ----------------------------------------
# Function to display the banner
show_banner() {                       
    printf "\033[1;33m" # Yellow and bold
    echo " _____ _____ __        _   "
    echo "|     |_   _|  |   ___| |_ "
    echo "|  |  | | | |  |__| .'| . |"
    echo "|_____| |_| |_____|__,|___|"
    printf "\033[1;37m" # White and bold
    printf "Exercise:  13-Jump Host\n"
    printf "Version:   1.0\n"
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
  # Corporate Workstations
  # ----------------------------------------
  $pc1_name:
    image: $base_image
    container_name: $pc1_name
    hostname: $pc1_name
    mac_address: 00:0B:DB:CC:00:01
    entrypoint: []
    command: bash -c "\
      apt update && \
      apt install -y iputils-ping iproute2 net-tools netdiscover traceroute nmap masscan tcpdump arp-scan arping fping openssh-server netcat-openbsd && \
      ip route add 172.30.10.0/27 via 172.30.0.254 && \
      echo '[i] Current routing table. . .' && ip route && \
      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $corp_net:
        ipv4_address: 172.30.0.10

  $pc2_name:
    image: $base_image
    container_name: $pc2_name
    hostname: $pc2_name
    mac_address: 00:0B:DB:CC:00:02
    entrypoint: []
    command: bash -c "\
      apt update && \
      apt install -y iputils-ping iproute2 net-tools netdiscover traceroute nmap masscan tcpdump arp-scan arping fping openssh-server netcat-openbsd && \
      ip route add 172.30.10.0/27 via 172.30.0.254 && \
      echo '[i] Current routing table. . .' && ip route && \
      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $corp_net:
        ipv4_address: 172.30.0.11

  $pc3_name:
    image: $base_image
    container_name: $pc3_name
    hostname: $pc3_name
    mac_address: 00:0B:DB:CC:00:03 
    entrypoint: []
    command: bash -c "\
      apt update && \
      apt install -y iputils-ping iproute2 net-tools netdiscover traceroute nmap masscan tcpdump arp-scan arping fping openssh-server netcat-openbsd && \
      mkdir -p /otlab && \
      printf '%s\n' \
        '# Jump Host Temporary Maintenance Credentials' \
        'ssh-user=root' \
        'ssh-pass=otlab123' \
        'ssh ssh-user@<IP_Address>' \
        > /otlab/jump-access.txt && \
      ip route add 172.30.10.0/27 via 172.30.0.254 && \
      echo '[i] Current routing table. . .' && ip route && \
      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $corp_net:
        ipv4_address: 172.30.0.12
  
  $gw_name:
    image: $ubuntu_image
    container_name: $gw_name
    hostname: $gw_name
    mac_address: 00:21:27:D3:0A:55
    entrypoint: []
    command: bash -c "\
      apt update && apt install -y iproute2 net-tools && \
      echo '[i] Current routing table. . .' && ip route && \
      tail -f /dev/null"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    sysctls:
      net.ipv4.ip_forward: "1"
    networks:
      $corp_net:
        ipv4_address: 172.30.0.254
      $dmz_net:
        ipv4_address: 172.30.10.30
  
  # ----------------------------------------
  # DMZ
  # ----------------------------------------
  $jump_name:
    image: $ubuntu_image
    container_name: $jump_name
    hostname: $jump_name
    mac_address: 00:01:E6:CC:10:01
    entrypoint: []
    command: bash -c "\
      apt update && \
      apt install -y iputils-ping iproute2 net-tools netdiscover traceroute nmap masscan openssh-server tcpdump traceroute rsyslog ufw snmp procps curl && \
      mkdir -p /otlab && \
      printf '%s\n' \
        '# Successful Access to the Jump Host!' \
        'OTLab13{Jump_To_The_Flag!}' \
        > /otlab/jump-flag.txt && \
      mkdir -p /run/sshd && \
      echo 'root:otlab123' | chpasswd && \
      sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
      sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
      echo '*.* @172.30.10.20:514' > /etc/rsyslog.d/10-logserver.conf && \
      /usr/sbin/rsyslogd && \
      logger -t OTLab13 "OTLab13{Hey_Log_Server_I_Am_Working}" && \
      ip route add 172.30.0.0/24 via 172.30.10.30 && \
      echo '[i] Current routing table:' && ip route && \
      ufw --force reset && \
      ufw default deny incoming && \
      ufw default allow outgoing && \
      ufw allow proto tcp from 172.30.0.12 to any port 22 && \
      ufw allow proto udp from 172.30.0.12 to any port 514 && \
      ufw deny from 172.30.0.0/24 && \
      ufw allow in on eth0 from 172.30.20.0/28 && \
      ufw deny out to 172.30.0.0/24 && \
      ufw --force enable && \
      iptables -I ufw-before-input 1 -p icmp --icmp-type echo-request -s 172.30.0.10 -j DROP && \
      iptables -I ufw-before-input 1 -p icmp --icmp-type echo-request -s 172.30.0.11 -j DROP && \
      exec /usr/sbin/sshd -D"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $dmz_net:
        ipv4_address: 172.30.10.10
      $ot_net:
        ipv4_address: 172.30.20.5

  $log_name:
    image: $ubuntu_image
    container_name: $log_name
    hostname: $log_name
    mac_address: 00:01:E6:CC:10:02
    entrypoint: []
    command: bash -c "\
      apt update && \
      apt install -y netcat-openbsd iputils-ping iproute2 net-tools && \
      echo '[i] Listening on UDP 514. . .' && \
      nc -klu 0.0.0.0 514 >> /var/log/otlab13.log"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $dmz_net:
        ipv4_address: 172.30.10.20

  # ----------------------------------------
  # OT-ICS
  # ----------------------------------------
  $ot1_name:
    image: iotechsys/s7-sim
    container_name: $ot1_name
    hostname: $ot1_name
    mac_address: 00:1C:06:CC:20:01
    cap_add:
      - NET_ADMIN
      - NET_RAW
    ports:
      - "102:102"
    privileged: true
    networks:
      $ot_net:
        ipv4_address: 172.30.20.11

  $ot2_name:
    image: honeynet/conpot:latest
    container_name: $ot2_name
    hostname: $ot2_name
    mac_address: 00:00:54:CC:20:02
    command: >
      sh -c '
        echo "<!DOCTYPE html><html><head><title>PLC Login</title><script>function login() { var user = document.getElementById(\"user\").value; var pass = document.getElementById(\"pass\").value; if (user === \"admin\" && pass === \"password\") { document.body.innerHTML = \"<h1>System successfully unlocked:</h1><p>OTLab13{Default_Credentials}</p>\"; } else { alert(\"Access denied!\"); } }</script></head><body><h2>User Management and Access Control Panel</h2><input type=\\"text\\" id=\\"user\\" placeholder=\\"Username\\"><br><input type=\\"password\\" id=\\"pass\\" placeholder=\\"Password\\"><br><br><button onclick=\\"login()\\">Login</button></body></html>" > /home/conpot/.local/lib/python3.6/site-packages/conpot-0.6.0-py3.6.egg/conpot/templates/default/http/htdocs/index.html &&
        /home/conpot/.local/bin/conpot -f --template default
      '
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $ot_net:
        ipv4_address: 172.30.20.12

  $hmi_name:
    image: $ubuntu_image
    container_name: $hmi_name
    hostname: $hmi_name
    mac_address: 00:00:54:CC:20:03
    volumes:
      - ./BroadcastUDP.py:/opt/BroadcastUDP.py:ro
    command: bash -c "\
      apt update && \
      apt install -y --no-install-recommends python3 && \
      rm -rf /var/lib/apt/lists/* && \
      python3 /opt/BroadcastUDP.py"
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      $ot_net:
        ipv4_address: 172.30.20.13

networks:
  $corp_net:
    name: $corp_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/24

  $dmz_net:
    name: $dmz_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.10.0/27

  $ot_net:
    name: $ot_net
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.20.0/28
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
        if container_exists "$pc1_name" || container_exists "$pc2_name" || container_exists "$pc3_name" || \
           container_exists "$gw_name" || container_exists "$jump_name" || container_exists "$log_name" || \
           container_exists "$ot1_name" || container_exists "$ot2_name" || container_exists "$hmi_name"; then
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
        docker network rm "$corp_net" "$dmz_net" "$ot_net" 2>/dev/null
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
            jump) target_name="$jump_name" ;;
            log) target_name="$log_name" ;;
            ot1) target_name="$ot1_name" ;;
            ot2) target_name="$ot2_name" ;;
            hmi) target_name="$hmi_name" ;;
            *)
                printf "\033[31m[Error]\033[0m Invalid target. Use one of: pc1|pc2|pc3|jump|log|ot1|ot2|hmi\n"
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
        echo "Usage: $0 -start [parrot|ubuntu] | -stop | -clean | -run [pc1|pc2|pc3|jump|log|ot1|ot2|hmi] | -restart | -status"
        echo ""
        echo "  -start     Start the $lab_name environment using the specified distro (default: ubuntu)"
        echo "             Valid options: parrot (parrotsec/core) or ubuntu (22.04)"
        echo "  -run       Open a terminal inside one container (pc1|pc2|pc3|jump|log|ot1|ot2|hmi)"
        echo "  -clean     Remove containers, volumes, and networks"
        echo "  -stop      Stop all containers"
        echo "  -restart   Restart previously stopped containers"
        echo "  -status    Show current containers status"
        exit 1
        ;;
esac