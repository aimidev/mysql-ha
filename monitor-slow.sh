#!/bin/bash

echo "=== MYSQL SLOW QUERY MONITOR ==="
echo ""

# Enable slow query log if not enabled
docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;
SHOW VARIABLES LIKE 'slow_query_log%';
" 2>/dev/null

echo ""
echo "🐌 MONITORING SLOW QUERIES (>1 second)..."
echo ""

while true; do
    echo "$(date): Checking for slow queries..."
    
    # Show recent slow queries
    docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
    SELECT 
        start_time,
        user_host,
        query_time,
        lock_time,
        rows_sent,
        rows_examined,
        LEFT(sql_text, 100) as query_preview
    FROM mysql.slow_log 
    WHERE start_time > DATE_SUB(NOW(), INTERVAL 10 SECOND)
    ORDER BY start_time DESC
    LIMIT 5;
    " 2>/dev/null
    
    sleep 5
done
