#!/bin/bash

echo "=== MYSQL REALTIME MONITORING ==="
echo ""

while true; do
    clear
    echo "🔥 MYSQL REALTIME QUERY MONITOR - $(date)"
    echo "=================================================="
    
    # Active connections and queries
    echo ""
    echo "📊 ACTIVE CONNECTIONS & QUERIES:"
    docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
    SELECT 
        COUNT(*) as Total_Connections,
        SUM(CASE WHEN COMMAND != 'Sleep' THEN 1 ELSE 0 END) as Active_Queries,
        SUM(CASE WHEN COMMAND = 'Sleep' THEN 1 ELSE 0 END) as Idle_Connections
    FROM INFORMATION_SCHEMA.PROCESSLIST;
    " 2>/dev/null
    
    echo ""
    echo "🚀 RUNNING QUERIES:"
    docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
    SELECT 
        ID,
        USER,
        HOST,
        DB,
        COMMAND,
        TIME as Duration_Sec,
        LEFT(INFO, 80) as Query_Preview
    FROM INFORMATION_SCHEMA.PROCESSLIST 
    WHERE COMMAND != 'Sleep' AND ID != CONNECTION_ID()
    ORDER BY TIME DESC;
    " 2>/dev/null
    
    echo ""
    echo "📈 PERFORMANCE STATS:"
    docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
    SHOW STATUS WHERE Variable_name IN (
        'Threads_connected',
        'Threads_running', 
        'Questions',
        'Queries',
        'Slow_queries',
        'Connections'
    );
    " 2>/dev/null
    
    echo ""
    echo "💾 RESOURCE USAGE:"
    docker stats mysql_primary --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    
    echo ""
    echo "Press Ctrl+C to stop monitoring..."
    sleep 2
done
