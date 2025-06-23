#!/bin/bash

# Enhanced CORS Testing Script for Railway + GitHub Pages + Localhost
# This script tests CORS configuration across all environments

echo "🧪 Enhanced CORS Testing Script"
echo "=================================================="

RAILWAY_URL="https://easysh-production-up.railway.app"
LOCALHOST_URL="http://localhost:8000"
GITHUB_PAGES_ORIGIN="https://vakac995.github.io/easySH/"
LOCALHOST_ORIGIN="http://localhost:5173"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local url=$1
    local origin=$2
    local endpoint=$3
    local method=${4:-GET}
    local description=$5
    local verbose=$6

    echo -e "${YELLOW}Testing: $description${NC}"
    echo "URL: $url$endpoint"
    echo "Origin: $origin"
    echo "Method: $method"

    if [ "$verbose" = "verbose" ]; then
        curl -v -H "Origin: $origin" "$url$endpoint" 2>&1 | grep -E "(< |> )(Access-Control|Origin|HTTP|Vary)" | head -10
        echo ""
        return
    fi

    if [ "$method" = "GET" ]; then
        RESPONSE=$(curl -s -w "%{http_code}" -H "Origin: $origin" "$url$endpoint" 2>/dev/null)
    else
        RESPONSE=$(curl -s -w "%{http_code}" -X "$method" -H "Origin: $origin" -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: Content-Type" "$url$endpoint" 2>/dev/null)
    fi

    HTTP_CODE="${RESPONSE: -3}"
    BODY="${RESPONSE%???}" # Remove last 3 characters (HTTP code)

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        echo -e "${GREEN}✅ SUCCESS (HTTP $HTTP_CODE)${NC}"
        if [ -n "$BODY" ] && [ "$BODY" != "null" ]; then
            echo "Response: $BODY"
        fi
    else
        echo -e "${RED}❌ FAILED (HTTP $HTTP_CODE)${NC}"
        if [ -n "$BODY" ] && [ "$BODY" != "null" ]; then
            echo "Response: $BODY"
        fi
    fi
    echo ""
}

echo "=== LOCALHOST BACKEND TESTING ==="
echo ""

# Test 1: Localhost availability
echo "1. Testing localhost backend availability..."
if curl -s -f "$LOCALHOST_URL/" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Localhost backend is accessible${NC}"
else
    echo -e "${RED}❌ Localhost backend is not accessible${NC}"
    echo "Make sure you started the backend with: cd backend && uvicorn main:app --reload"
    echo ""
fi

# Test 2: Localhost health endpoint
test_endpoint "$LOCALHOST_URL" "" "/health" "GET" "Localhost health endpoint"

# Test 3: Localhost CORS test endpoint
test_endpoint "$LOCALHOST_URL" "$LOCALHOST_ORIGIN" "/api/cors-test" "GET" "Localhost CORS test endpoint with localhost origin"

# Test 4: Localhost preflight OPTIONS
test_endpoint "$LOCALHOST_URL" "$LOCALHOST_ORIGIN" "/api/generate" "OPTIONS" "Localhost OPTIONS preflight request"

echo "=== RAILWAY BACKEND TESTING ==="
echo ""

# Test 5: Railway availability
echo "2. Testing Railway backend availability..."
if curl -s -f "$RAILWAY_URL/" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Railway backend is accessible${NC}"
else
    echo -e "${RED}❌ Railway backend is not accessible${NC}"
    echo ""
fi

# Test 6: Railway health endpoint
test_endpoint "$RAILWAY_URL" "" "/health" "GET" "Railway health endpoint"

# Test 7: Railway CORS test endpoint with GitHub Pages origin
test_endpoint "$RAILWAY_URL" "$GITHUB_PAGES_ORIGIN" "/api/cors-test" "GET" "Railway CORS test with GitHub Pages origin"

# Test 8: Railway preflight OPTIONS
test_endpoint "$RAILWAY_URL" "$GITHUB_PAGES_ORIGIN" "/api/generate" "OPTIONS" "Railway OPTIONS preflight request"

echo "=== CROSS-ORIGIN TESTING ==="
echo ""

# Test 9: Railway with localhost origin (should fail in production)
test_endpoint "$RAILWAY_URL" "$LOCALHOST_ORIGIN" "/api/cors-test" "GET" "Railway CORS test with localhost origin (should fail in prod)"

# Test 10: Detailed CORS headers inspection
echo "3. Detailed CORS headers inspection (Railway):"
echo -e "${YELLOW}Making verbose request to inspect all CORS headers:${NC}"
test_endpoint "$RAILWAY_URL" "$GITHUB_PAGES_ORIGIN" "/api/cors-test" "GET" "Detailed CORS headers inspection (Railway)" "verbose"

echo ""
echo "=================================================="
echo -e "${GREEN}🏁 Enhanced CORS Testing Complete!${NC}"
echo ""
echo "Summary:"
echo "- If localhost tests pass ✅, your local development setup is working"
echo "- If Railway tests pass ✅, your production deployment is working"
echo "- If GitHub Pages can access Railway ✅, your CORS configuration is correct"
echo ""
echo "Next steps:"
echo "1. If localhost works but Railway doesn't, redeploy to Railway"
echo "2. If Railway works but CORS fails, check the allowed origins configuration"
echo "3. Test in browser: open GitHub Pages site and check network tab"
