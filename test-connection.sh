#!/bin/bash

echo "=== TESTING MYSQL CONNECTION ==="
echo ""

# Test dengan container MySQL client
echo "🧪 Testing with Docker MySQL client..."
docker run --rm mysql:8.0 mysql -h138.201.240.157 -P3310 -uflimtrack_user -pFlimTrack2024!User --ssl-mode=DISABLED -e "SELECT 'Direct connection works!' as test;" 2>/dev/null

echo ""
echo "🧪 Testing HAProxy connection..."
docker run --rm mysql:8.0 mysql -h138.201.240.157 -P3356 -uflimtrack_user -pFlimTrack2024!User --ssl-mode=DISABLED -e "SELECT 'HAProxy connection works!' as test;" 2>/dev/null

echo ""
echo "📋 Connection strings to try:"
echo ""
echo "1. Direct MySQL (bypass HAProxy):"
echo "   mysql -h138.201.240.157 -P3310 -uflimtrack_user -pFlimTrack2024!User --ssl-mode=DISABLED"
echo ""
echo "2. With skip-ssl:"
echo "   mysql -h138.201.240.157 -P3310 -uflimtrack_user -pFlimTrack2024!User --skip-ssl"
echo ""
echo "3. Force no SSL:"
echo "   mysql -h138.201.240.157 -P3310 -uflimtrack_user -pFlimTrack2024!User --ssl=0"
