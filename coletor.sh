#! /usr/bin/bash

# Coleta dados sobre o host
# Dados Coletados
#   - Uso de CPU total
#   - Uso de memória total
#   - Endereço de IP
collect() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    memory_info=$(free -m | grep "Mem:")
    memory_total=$(echo $memory_info | awk '{print $2}')
    memory_used=$(echo $memory_info | awk '{print $3}')
    memory_percent=$(echo "scale=2; $memory_used / $memory_total * 100" | bc)

    ip_address=$(hostname -I | awk '{print $1}')

    source .env
    QUERY_SQL="insert into infos (uso_cpu, memoria, ip) values ($cpu_usage, $memory_used, '$ip_address')"
    POSTGRES_URI=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:9999/postgres
    echo Executando: $POSTGRES_URI "|" $QUERY_SQL

    psql "${POSTGRES_URI}" -c "${QUERY_SQL}"
}

# Fica em loop coletando os dados
interval="${1:-60}"
while true; do
    collect
    sleep "$interval"
done