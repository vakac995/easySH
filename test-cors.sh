#!/bin/bash

# CORS Testing Script for Railway + GitHub Pages
# This script tests CORS configuration between your GitHub Pages frontend and Railway backend

echo "🧪 Testing CORS Configuration between GitHub Pages and Railway..."
echo "=================================================="

RAILWAY_URL="https://easysh-production-up.railway.app"
GITHUB_PAGES_ORIGIN="https://vakac995.github.io"

echo "1. Testing Railway backend availability..."
if curl -s -f "$RAILWAY_URL/" > /dev/null; then
    echo "✅ Railway backend is accessible"
else
    echo "❌ Railway backend is not accessible"
    exit 1
fi

echo ""
echo "2. Testing FastAPI docs endpoint..."
if curl -s -f "$RAILWAY_URL/docs" > /dev/null; then
    echo "✅ FastAPI docs are accessible"
else
    echo "❌ FastAPI docs are not accessible - backend may not be running correctly"
fi

echo ""
echo "3. Testing CORS test endpoint..."
CORS_RESPONSE=$(curl -s -w "%{http_code}" -H "Origin: $GITHUB_PAGES_ORIGIN" "$RAILWAY_URL/api/cors-test")
HTTP_CODE="${CORS_RESPONSE: -3}"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ CORS test endpoint is working"
    echo "Response: ${CORS_RESPONSE%???}"  # Remove last 3 characters (HTTP code)
else
    echo "❌ CORS test endpoint failed (HTTP $HTTP_CODE)"
fi

echo ""
echo "4. Testing preflight OPTIONS request..."
OPTIONS_RESPONSE=$(curl -s -w "%{http_code}" -X OPTIONS \
    -H "Origin: $GITHUB_PAGES_ORIGIN" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type" \
    "$RAILWAY_URL/api/generate")
OPTIONS_CODE="${OPTIONS_RESPONSE: -3}"

if [ "$OPTIONS_CODE" = "200" ]; then
    echo "✅ OPTIONS preflight request is working"
else
    echo "❌ OPTIONS preflight request failed (HTTP $OPTIONS_CODE)"
fi

echo ""
echo "5. Testing with verbose CORS headers..."
echo "Making request with full header inspection:"
curl -v -H "Origin: $GITHUB_PAGES_ORIGIN" "$RAILWAY_URL/api/cors-test" 2>&1 | grep -E "(< |> )(Access-Control|Origin|HTTP)"

echo ""
echo "=================================================="
echo "🏁 CORS Testing Complete!"
echo ""
echo "If all tests pass ✅, your CORS configuration is working correctly."
echo "If any tests fail ❌, check the Railway deployment and backend configuration."
