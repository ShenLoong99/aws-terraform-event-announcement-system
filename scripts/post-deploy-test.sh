#!/bin/bash
# scripts/post-deploy-test.sh

echo "🚀 Starting Post-Deployment Tests..."

# 1. Check Frontend Availability
echo "🔍 Testing Frontend: $WEBSITE_URL"
STATUS_FRONTEND=$(curl -s -o /dev/null -w "%{http_code}" "$WEBSITE_URL")
if [ "$STATUS_FRONTEND" -eq 200 ]; then
    echo "✅ Frontend is reachable (HTTP 200)"
else
    echo "❌ Frontend check failed (HTTP $STATUS_FRONTEND)"
    exit 1
fi

# 2. Check API Health (Subscribe Endpoint)
echo "🔍 Testing API Endpoint: $API_URL/subscribe"
STATUS_API=$(curl -s -o /dev/null -w "%{http_code}" -X OPTIONS "$API_URL/subscribe")
if [ "$STATUS_API" -eq 200 ]; then
    echo "✅ API Gateway OPTIONS/CORS is active (HTTP 200)"
else
    echo "❌ API Gateway check failed (HTTP $STATUS_API)"
    exit 1
fi

# 3. Verify API URL Injection in Frontend
echo "🔍 Verifying Terraform Template Injection..."
if curl -s "$WEBSITE_URL" | grep -q "execute-api"; then
    echo "✅ API URL correctly injected into index.html"
else
    echo "❌ API URL missing from frontend. Check terraform templatefile logic."
    exit 1
fi

echo "🎉 All Post-Deployment Tests Passed!"
