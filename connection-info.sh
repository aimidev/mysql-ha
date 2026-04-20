#!/bin/bash

echo "=== MYSQL CONNECTION TEST ==="
echo ""

SERVER_IP="138.201.240.157"
echo "🌐 Server IP: $SERVER_IP"
echo ""

echo "📋 CONNECTION DETAILS:"
echo "  • MySQL Direct:     $SERVER_IP:3310"
echo "  • Load Balancer:    $SERVER_IP:3356"
echo "  • Redis Cache:      $SERVER_IP:6381"
echo ""
echo "  • Database:         flimtrack_db"
echo "  • Username:         flimtrack_user"
echo "  • Password:         FlimTrack2024!User"
echo ""

echo "🔧 CONNECTION COMMANDS (WORKING):"
echo ""
echo "MySQL Direct (Port 3310):"
echo "  mysql -h$SERVER_IP -P3310 -uflimtrack_user -pFlimTrack2024!User flimtrack_db --ssl-mode=DISABLED"
echo ""
echo "Via HAProxy Load Balancer (Port 3356):"
echo "  mysql -h$SERVER_IP -P3356 -uflimtrack_user -pFlimTrack2024!User flimtrack_db --ssl-mode=DISABLED"
echo ""
echo "Alternative SSL options:"
echo "  --skip-ssl  or  --ssl=0"
echo ""
echo "Redis:"
echo "  redis-cli -h $SERVER_IP -p 6381 -a FlimTrack2024!Redis"
echo ""

echo "🧪 TESTING PORTS:"
for port in 3310 3356 6381; do
    if timeout 3 bash -c "</dev/tcp/$SERVER_IP/$port" 2>/dev/null; then
        echo "  ✅ Port $port: OPEN"
    else
        echo "  ❌ Port $port: CLOSED/FILTERED"
    fi
done

echo ""
echo "📱 APPLICATION CONFIG:"
echo "  Host: $SERVER_IP"
echo "  Port: 3356 (recommended - load balanced)"
echo "  Alt:  3310 (direct MySQL)"
