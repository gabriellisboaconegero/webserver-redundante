#! /usr/bin/bash

# Coleta dados sobre o host
# Dados Coletados
#   - Uso de CPU total
#   - Uso de memória total
#   - Endereço de IP
collect() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

    memory_info=$(free -m | grep "Mem:")
    memory_total=$(echo $memory_info | awk '{print $2}')
    memory_used=$(echo $memory_info | awk '{print $3}')
    memory_percent=$(echo "scale=2; $memory_used / $memory_total * 100" | bc)

    ip_address=$(hostname -I)

    echo "CPU Usage (%): $cpu_usage"
    echo "Memory Usage (%): $memory_percent%"
    echo "IP Address: $ip_address"
}

# Fica em loop coletando os dados
interval="${1:-60}"
while true; do
    collect
    sleep "$interval"
done