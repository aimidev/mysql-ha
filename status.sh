#!/bin/bash

echo "=== HIGH PERFORMANCE MYSQL CLUSTER STATUS ==="
echo ""

echo "🚀 SERVICES STATUS:"
docker-compose -f docker-compose-simple-ha.yml ps

echo ""
echo "📊 MYSQL PERFORMANCE SETTINGS:"
docker exec mysql_primary mysql -uroot -pFlimTrack2024!Root -e "
SELECT 
    'Max Connections' as Setting, @@max_connections as Value
UNION ALL SELECT 
    'Buffer Pool (GB)', ROUND(@@innodb_buffer_pool_size/1024/1024/1024, 2)
UNION ALL SELECT 
    'InnoDB IO Capacity', @@innodb_io_capacity
UNION ALL SELECT 
    'Thread Cache Size', @@thread_cache_size
UNION ALL SELECT 
    'Table Open Cache', @@table_open_cache;
" 2>/dev/null

echo ""
echo "💾 DISK USAGE:"
df -h /home/backups-disk2/mysql-primary | tail -1

echo ""
echo "🔗 CONNECTION ENDPOINTS:"
echo "  • Primary MySQL:    localhost:3310"
echo "  • Load Balancer:    localhost:3356 (via HAProxy)"
echo "  • Redis Cache:      localhost:6381"
echo "  • HAProxy Stats:    http://localhost:8082/stats"

echo ""
echo "⚡ PERFORMANCE FEATURES:"
echo "  ✅ 2000 max connections"
echo "  ✅ 4GB InnoDB buffer pool"
echo "  ✅ Optimized for complex queries"
echo "  ✅ Redis caching available"
echo "  ✅ Data on fast SSD (disk2)"
echo "  ✅ Connection pooling ready"

echo ""
echo "🔧 QUICK COMMANDS:"
echo "  • Start:   docker-compose -f docker-compose-simple-ha.yml up -d"
echo "  • Stop:    docker-compose -f docker-compose-simple-ha.yml down"
echo "  • Logs:    docker-compose -f docker-compose-simple-ha.yml logs -f"
echo "  • Connect: mysql -h127.0.0.1 -P3310 -uflimtrack_user -p"
