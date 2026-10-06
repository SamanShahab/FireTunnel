#!/bin/bash
BACKEND="http://192.168.56.1:5001/api"
TOKEN=$(curl -s -X POST "$BACKEND/auth/login" -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: $TOKEN"
SCENARIO="MINIMAL"
LATENCY_GUEST=$(ping -c 5 -W 2 192.168.30.10 | tail -1 | awk -F'/' '{print $5}' 2>/dev/null || echo "2.5")
curl -s -X POST "$BACKEND/events" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"source\":\"192.168.30.10\",\"sourceZone\":\"GUEST\",\"destination\":\"192.168.10.10\",\"destinationZone\":\"INTERNAL\",\"protocol\":\"ICMP\",\"port\":0,\"action\":\"ALLOW\",\"reason\":\"No firewall - Guest reaches Internal\",\"scenario\":\"$SCENARIO\"}"
echo "Guest event pushed"
LATENCY_DMZ=$(ping -c 5 -W 2 192.168.20.10 | tail -1 | awk -F'/' '{print $5}' 2>/dev/null || echo "2.8")
curl -s -X POST "$BACKEND/events" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"source\":\"192.168.20.10\",\"sourceZone\":\"DMZ\",\"destination\":\"192.168.10.10\",\"destinationZone\":\"INTERNAL\",\"protocol\":\"ICMP\",\"port\":0,\"action\":\"ALLOW\",\"reason\":\"No DMZ isolation - DMZ reaches Internal\",\"scenario\":\"$SCENARIO\"}"
echo "DMZ event pushed"
curl -s -X POST "$BACKEND/performance" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"scenario\":\"$SCENARIO\",\"metricType\":\"LATENCY\",\"run\":1,\"value\":$LATENCY_GUEST,\"unit\":\"ms\",\"source\":\"192.168.30.10\",\"destination\":\"192.168.10.10\"}"
echo "Guest metric pushed"
curl -s -X POST "$BACKEND/performance" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"scenario\":\"$SCENARIO\",\"metricType\":\"LATENCY\",\"run\":2,\"value\":$LATENCY_DMZ,\"unit\":\"ms\",\"source\":\"192.168.20.10\",\"destination\":\"192.168.10.10\"}"
echo "DMZ metric pushed"
