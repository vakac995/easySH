#!/bin/bash

# EasySH API Test Runner
# This script runs comprehensive API tests using Newman (Postman CLI)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COLLECTION_FILE="EasySH-API-Collection.json"
DEV_ENV_FILE="EasySH-Development.postman_environment.json"
PROD_ENV_FILE="EasySH-Production.postman_environment.json"
RESULTS_DIR="test-results"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}🚀 EasySH API Test Suite${NC}"
echo "======================================="

# Check if Newman is installed
if ! command -v newman &> /dev/null; then
    echo -e "${RED}❌ Newman is not installed. Please install it first:${NC}"
    echo "npm install -g newman"
    exit 1
fi

# Function to run tests
run_tests() {
    local env_name=$1
    local env_file=$2
    local report_suffix=$3
    
    echo -e "${YELLOW}🧪 Running tests for $env_name environment...${NC}"
    
    newman run "$COLLECTION_FILE" \
        -e "$env_file" \
        --reporters cli,htmlextra,json \
        --reporter-htmlextra-export "$RESULTS_DIR/report-$report_suffix.html" \
        --reporter-json-export "$RESULTS_DIR/results-$report_suffix.json" \
        --timeout-request 30000 \
        --delay-request 100 \
        --bail \
        --color on
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $env_name tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ $env_name tests failed!${NC}"
        return 1
    fi
}

# Function to run load tests
run_load_tests() {
    local env_name=$1
    local env_file=$2
    local report_suffix=$3
    
    echo -e "${YELLOW}⚡ Running load tests for $env_name environment...${NC}"
    
    newman run "$COLLECTION_FILE" \
        -e "$env_file" \
        --folder "Load Testing" \
        --reporters cli,htmlextra,json \
        --reporter-htmlextra-export "$RESULTS_DIR/load-report-$report_suffix.html" \
        --reporter-json-export "$RESULTS_DIR/load-results-$report_suffix.json" \
        --timeout-request 30000 \
        --delay-request 50 \
        --iteration-count 5 \
        --color on
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $env_name load tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ $env_name load tests failed!${NC}"
        return 1
    fi
}

# Main execution
case "$1" in
    "dev")
        echo -e "${BLUE}Running Development Environment Tests${NC}"
        run_tests "Development" "$DEV_ENV_FILE" "dev"
        ;;
    "prod")
        echo -e "${BLUE}Running Production Environment Tests${NC}"
        run_tests "Production" "$PROD_ENV_FILE" "prod"
        ;;
    "load-dev")
        echo -e "${BLUE}Running Development Load Tests${NC}"
        run_load_tests "Development" "$DEV_ENV_FILE" "dev"
        ;;
    "load-prod")
        echo -e "${BLUE}Running Production Load Tests${NC}"
        run_load_tests "Production" "$PROD_ENV_FILE" "prod"
        ;;
    "all")
        echo -e "${BLUE}Running All Tests${NC}"
        run_tests "Development" "$DEV_ENV_FILE" "dev" && \
        run_tests "Production" "$PROD_ENV_FILE" "prod" && \
        run_load_tests "Development" "$DEV_ENV_FILE" "dev" && \
        run_load_tests "Production" "$PROD_ENV_FILE" "prod"
        ;;
    "health")
        echo -e "${BLUE}Running Health Check Tests Only${NC}"
        newman run "$COLLECTION_FILE" \
            -e "$DEV_ENV_FILE" \
            --folder "Health Check & CORS" \
            --reporters cli \
            --color on
        ;;
    *)
        echo -e "${YELLOW}Usage: $0 {dev|prod|load-dev|load-prod|all|health}${NC}"
        echo ""
        echo "Commands:"
        echo "  dev       - Run all tests against development environment"
        echo "  prod      - Run all tests against production environment"
        echo "  load-dev  - Run load tests against development environment"
        echo "  load-prod - Run load tests against production environment"
        echo "  all       - Run all tests against both environments"
        echo "  health    - Run only health check tests"
        echo ""
        echo "Reports will be saved in the '$RESULTS_DIR' directory"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Test execution completed!${NC}"
echo -e "${BLUE}📊 Check the reports in the '$RESULTS_DIR' directory${NC}"
