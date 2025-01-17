#! /usr/bin/bash
set -e
PGPOOL_HOST=localhost
PGPOOL_PORT=9999

source .env

check_retry_count () {
    RETRY_COUNT=$1
    MAX_RETRY=10
    failed_db_host=$2
    if [ $RETRY_COUNT -eq $MAX_RETRY ]; then
        echo "Maximum retry for checking $failed_db_host to be online is reached, exiting..."
        exit 3
    fi
}

RETRY_COUNT=0
until psql -l postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${PGPOOL_HOST}:${PGPOOL_PORT}; do
    check_retry_count $RETRY_COUNT "pgpool on ($PGPOOL_HOST:$PGPOOL_PORT)"
    ((RETRY_COUNT=RETRY_COUNT+1))

    echo "$(date) - waiting for pgpool on ($PGPOOL_HOST:$PGPOOL_PORT) to be online..."
    sleep 3s
done
echo "*** pgpool on ($PGPOOL_HOST:$PGPOOL_PORT) host is online ***"

# Coleta dados sobre o host
# Dados Coletados
#   - Uso de CPU total
#   - Uso de memória total
#   - Endereço de IP
#   - Latência com google.com
collect() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    memory_info=$(free -m | grep "Mem:")
    memory_total=$(echo $memory_info | awk '{print $2}')
    memory_used=$(echo $memory_info | awk '{print $3}')
    memory_percent=$(echo "scale=2; $memory_used / $memory_total * 100" | bc)

    ip_address=$(hostname -I | awk '{print $1}')
    ping_info=$(ping -c 1 google.com | grep 'time=' | cut -d'=' -f4 | awk '{print $1}')

    QUERY_SQL="insert into infos (uso_cpu, memoria, ip, ping_info) values ($cpu_usage, $memory_used, '$ip_address', $ping_info)"
    POSTGRES_URI=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${PGPOOL_HOST}:${PGPOOL_PORT}/postgres
    echo Executando: $POSTGRES_URI "|" $QUERY_SQL

    if ! psql -1 "${POSTGRES_URI}" -f <(echo "${QUERY_SQL}"); then
        echo "Erro ao salvar dados no banco ${POSTGRES_URI}"
    fi
}

# Fica em loop coletando os dados
interval="${1:-60}"
while true; do
    collect
    sleep "$interval"
done