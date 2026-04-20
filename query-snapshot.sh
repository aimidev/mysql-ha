#!/bin/bash

echo "=== MYSQL QUERY PERFORMANCE DASHBOARD ==="
echo ""

# One-time snapshot
echo "📊 CURRENT QUERY PERFORMANCE:"
docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
SELECT 
    'Active Connections' as Metric,
    COUNT(*) as Value
FROM INFORMATION_SCHEMA.PROCESSLIST
UNION ALL
SELECT 
    'Running Queries',
    COUNT(*)
FROM INFORMATION_SCHEMA.PROCESSLIST 
WHERE COMMAND != 'Sleep'
UNION ALL
SELECT 
    'Total Questions',
    VARIABLE_VALUE
FROM INFORMATION_SCHEMA.GLOBAL_STATUS 
WHERE VARIABLE_NAME = 'Questions'
UNION ALL
SELECT 
    'Queries Per Second (approx)',
    ROUND(VARIABLE_VALUE / UPTIME, 2)
FROM INFORMATION_SCHEMA.GLOBAL_STATUS s1
JOIN INFORMATION_SCHEMA.GLOBAL_STATUS s2 
WHERE s1.VARIABLE_NAME = 'Questions' 
AND s2.VARIABLE_NAME = 'Uptime';
" 2>/dev/null

echo ""
echo "🔍 ACTIVE QUERIES RIGHT NOW:"
docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
SELECT 
    ID,
    USER,
    HOST,
    DB,
    COMMAND,
    TIME as Seconds,
    STATE,
    LEFT(INFO, 60) as Query
FROM INFORMATION_SCHEMA.PROCESSLIST 
WHERE COMMAND != 'Sleep' 
AND ID != CONNECTION_ID()
ORDER BY TIME DESC;
" 2>/dev/null

echo ""
echo "📈 PERFORMANCE COUNTERS:"
docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
SHOW STATUS WHERE Variable_name IN (
    'Threads_connected',
    'Threads_running',
    'Questions', 
    'Com_select',
    'Com_insert',
    'Com_update',
    'Com_delete',
    'Slow_queries'
);
" 2>/dev/null
