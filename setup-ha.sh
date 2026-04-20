#!/bin/bash

# High Availability MySQL Setup Script

echo "Setting up High Availability MySQL Cluster..."

# 1. Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Please edit .env file with your secure passwords before continuing!"
    exit 1
fi

# 2. Start master first
echo "Starting MySQL Master..."
docker compose up -d mysql-master

# Wait for master to be ready
echo "Waiting for master to be ready..."
sleep 30

# 3. Start slaves
echo "Starting MySQL Slaves..."
docker compose up -d mysql-slave1 mysql-slave2

# Wait for slaves to be ready
echo "Waiting for slaves to be ready..."
sleep 30

# 4. Configure replication
echo "Configuring replication..."

# Get master status
MASTER_STATUS=$(docker exec mysql_master mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW MASTER STATUS\G")
MASTER_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

# Configure slave1
docker exec mysql_slave1 mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "
CHANGE MASTER TO 
MASTER_HOST='mysql-master',
MASTER_USER='replicator',
MASTER_PASSWORD='${MYSQL_REPLICATION_PASSWORD}',
MASTER_LOG_FILE='${MASTER_FILE}',
MASTER_LOG_POS=${MASTER_POS};
START SLAVE;"

# Configure slave2
docker exec mysql_slave2 mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "
CHANGE MASTER TO 
MASTER_HOST='mysql-master',
MASTER_USER='replicator',
MASTER_PASSWORD='${MYSQL_REPLICATION_PASSWORD}',
MASTER_LOG_FILE='${MASTER_FILE}',
MASTER_LOG_POS=${MASTER_POS};
START SLAVE;"

# 5. Start remaining services
echo "Starting ProxySQL, Redis, and HAProxy..."
docker compose up -d

echo "Setup complete!"
echo ""
echo "Connection endpoints:"
echo "- Application: localhost:3356 (HAProxy -> ProxySQL)"
echo "- Direct ProxySQL: localhost:6033"
echo "- Master direct: localhost:3306"
echo "- Slave1 direct: localhost:3307"
echo "- Slave2 direct: localhost:3308"
echo "- Redis: localhost:6379"
echo "- HAProxy Stats: http://localhost:8080/stats"
echo "- ProxySQL Admin: localhost:6032"
echo ""
echo "Performance features:"
echo "- 2000 max connections per MySQL instance"
echo "- Connection pooling via ProxySQL"
echo "- Read/Write splitting (reads go to slaves)"
echo "- Redis caching available"
echo "- Data stored on fast disk2 (/home/backups-disk2)"
