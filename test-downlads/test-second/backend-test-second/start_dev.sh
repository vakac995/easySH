#!/bin/bash
# Development server startup script

echo "🚀 Starting development server..."
echo "📍 URL: http://localhost:8000"
echo "📖 Docs: http://localhost:8000/docs"
echo "🔄 Auto-reload enabled"
echo ""

# Use uvicorn for development (with auto-reload)
uvicorn main:app --reload --host 0.0.0.0 --port 8000