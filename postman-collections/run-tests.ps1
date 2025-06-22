# EasySH API Test Runner (PowerShell)
# This script runs comprehensive API tests using Newman (Postman CLI)

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "prod", "load-dev", "load-prod", "all", "health")]
    [string]$Environment
)

# Configuration
$CollectionFile = "EasySH-API-Collection.json"
$DevEnvFile = "EasySH-Development.postman_environment.json"
$ProdEnvFile = "EasySH-Production.postman_environment.json"
$ResultsDir = "test-results"

# Create results directory
if (!(Test-Path $ResultsDir)) {
    New-Item -ItemType Directory -Path $ResultsDir | Out-Null
}

Write-Host "🚀 EasySH API Test Suite" -ForegroundColor Blue
Write-Host "======================================="

# Check if Newman is installed
try {
    newman --version | Out-Null
} catch {
    Write-Host "❌ Newman is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "npm install -g newman" -ForegroundColor Yellow
    Write-Host "npm install -g newman-reporter-htmlextra" -ForegroundColor Yellow
    exit 1
}

# Function to run tests
function Run-Tests {
    param(
        [string]$EnvName,
        [string]$EnvFile,
        [string]$ReportSuffix
    )
    
    Write-Host "🧪 Running tests for $EnvName environment..." -ForegroundColor Yellow
    
    $arguments = @(
        "run", $CollectionFile,
        "-e", $EnvFile,
        "--reporters", "cli,htmlextra,json",
        "--reporter-htmlextra-export", "$ResultsDir/report-$ReportSuffix.html",
        "--reporter-json-export", "$ResultsDir/results-$ReportSuffix.json",
        "--timeout-request", "30000",
        "--delay-request", "100",
        "--bail",
        "--color", "on"
    )
    
    & newman $arguments
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $EnvName tests passed!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $EnvName tests failed!" -ForegroundColor Red
        return $false
    }
}

# Function to run load tests
function Run-LoadTests {
    param(
        [string]$EnvName,
        [string]$EnvFile,
        [string]$ReportSuffix
    )
    
    Write-Host "⚡ Running load tests for $EnvName environment..." -ForegroundColor Yellow
    
    $arguments = @(
        "run", $CollectionFile,
        "-e", $EnvFile,
        "--folder", "Load Testing",
        "--reporters", "cli,htmlextra,json",
        "--reporter-htmlextra-export", "$ResultsDir/load-report-$ReportSuffix.html",
        "--reporter-json-export", "$ResultsDir/load-results-$ReportSuffix.json",
        "--timeout-request", "30000",
        "--delay-request", "50",
        "--iteration-count", "5",
        "--color", "on"
    )
    
    & newman $arguments
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $EnvName load tests passed!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $EnvName load tests failed!" -ForegroundColor Red
        return $false
    }
}

# Main execution
switch ($Environment) {
    "dev" {
        Write-Host "Running Development Environment Tests" -ForegroundColor Blue
        Run-Tests "Development" $DevEnvFile "dev"
    }
    "prod" {
        Write-Host "Running Production Environment Tests" -ForegroundColor Blue
        Run-Tests "Production" $ProdEnvFile "prod"
    }
    "load-dev" {
        Write-Host "Running Development Load Tests" -ForegroundColor Blue
        Run-LoadTests "Development" $DevEnvFile "dev"
    }
    "load-prod" {
        Write-Host "Running Production Load Tests" -ForegroundColor Blue
        Run-LoadTests "Production" $ProdEnvFile "prod"
    }
    "all" {
        Write-Host "Running All Tests" -ForegroundColor Blue
        $devResult = Run-Tests "Development" $DevEnvFile "dev"
        $prodResult = Run-Tests "Production" $ProdEnvFile "prod"
        $loadDevResult = Run-LoadTests "Development" $DevEnvFile "dev"
        $loadProdResult = Run-LoadTests "Production" $ProdEnvFile "prod"
        
        if (-not ($devResult -and $prodResult -and $loadDevResult -and $loadProdResult)) {
            exit 1
        }
    }
    "health" {
        Write-Host "Running Health Check Tests Only" -ForegroundColor Blue
        $arguments = @(
            "run", $CollectionFile,
            "-e", $DevEnvFile,
            "--folder", "Health Check & CORS",
            "--reporters", "cli",
            "--color", "on"
        )
        & newman $arguments
    }
}

Write-Host ""
Write-Host "🎉 Test execution completed!" -ForegroundColor Green
Write-Host "📊 Check the reports in the '$ResultsDir' directory" -ForegroundColor Blue

# Open results directory if tests were run
if ($Environment -ne "health") {
    if (Test-Path $ResultsDir) {
        Write-Host "Opening results directory..." -ForegroundColor Cyan
        Invoke-Item $ResultsDir
    }
}
