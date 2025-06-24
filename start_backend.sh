#!/bin/bash

# Simple Backend Starter for Port Forwarding
# Starts the backend and reminds about GitHub secrets

echo "🚀 Starting EasySH Backend for Port Forwarding"
echo "=============================================="
echo ""

# Navigate to backend and start
cd backend

echo "📦 Installing dependencies..."
pip install -r requirements.txt

echo ""
echo "🌐 Starting backend on http://localhost:8000"
echo "📡 After starting, forward port 8000 in VS Code (Ports tab → Public)"
echo "🔑 Update GitHub secret VITE_API_BASE_URL_PROD with your forwarded URL"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Start FastAPI with reload
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
