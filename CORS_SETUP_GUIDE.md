# Railway + GitHub Pages CORS Setup Guide

## Overview
This guide provides complete instructions for configuring CORS between your GitHub Pages frontend and Railway backend to eliminate cross-origin request issues.

## Current Configuration

### Railway Backend (FastAPI)
- **URL**: `https://easysh-production-up.railway.app`
- **CORS Origins**: 
  - `https://vakac995.github.io` (GitHub Pages main domain)
  - `https://vakac995.github.io/easySH` (Project-specific path)
  - `http://localhost:5173` (Local development)

### GitHub Pages Frontend
- **URL**: `https://vakac995.github.io/easySH/`
- **Base Path**: `/easySH/`
- **API Endpoint**: Points to Railway backend

## Step-by-Step Configuration

### 1. Railway Deployment Setup

#### A. Verify `railway.toml` Configuration
```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "uvicorn main:app --host 0.0.0.0 --port $PORT"
healthcheckPath = "/docs"
healthcheckTimeout = 100
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10

[env]
PORT = "8000"
```

#### B. Root `main.py` (Railway Entry Point)
```python
"""
Railway deployment entry point for easySH backend.
"""
import sys
import os
from pathlib import Path

# Add the project root to Python path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# Import the FastAPI app from backend
from backend.main import app

__all__ = ['app']
```

#### C. Backend CORS Configuration (`backend/main.py`)
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://vakac995.github.io",          # GitHub Pages main domain
        "https://vakac995.github.io/easySH",   # GitHub Pages project path
        "http://localhost:5173",               # Local development
        "http://127.0.0.1:5173",              # Alternative local dev
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=[
        "Accept", "Accept-Language", "Content-Language", "Content-Type",
        "Authorization", "X-Requested-With", "Origin",
        "Access-Control-Request-Method", "Access-Control-Request-Headers",
    ],
    expose_headers=["Content-Disposition"],
    max_age=86400,  # 24 hours
)
```

### 2. GitHub Pages Frontend Setup

#### A. Vite Configuration (`frontend/vite.config.ts`)
```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ command }) => ({
  plugins: [react()],
  base: command === 'build' ? '/easySH/' : '/',
  css: {
    postcss: './postcss.config.js',
  },
}));
```

#### B. API Configuration (`frontend/src/config/api.js`)
```javascript
const config = {
  development: {
    apiBaseUrl: 'http://localhost:8000',
  },
  production: {
    apiBaseUrl: 'https://easysh-production-up.railway.app',
  },
};

const environment = import.meta.env.MODE || 'development';
export const API_BASE_URL = config[environment].apiBaseUrl;
```

### 3. Deployment Process

#### A. Deploy Backend to Railway
```bash
# Commit your changes
git add .
git commit -m "fix: Update CORS configuration for Railway deployment"
git push origin main
```

Railway will automatically deploy when you push to your main branch.

#### B. Deploy Frontend to GitHub Pages
```bash
# Build the frontend
cd frontend
npm run build

# Deploy to GitHub Pages (if using gh-pages)
npm run deploy
```

Or configure GitHub Actions for automatic deployment.

### 4. Testing CORS Configuration

#### A. Test Backend Endpoints
```bash
# Test health check
curl -X GET "https://easysh-production-up.railway.app/docs"

# Test CORS with GitHub Pages origin
curl -X GET "https://easysh-production-up.railway.app/api/cors-test" \
     -H "Origin: https://vakac995.github.io"

# Test preflight request
curl -X OPTIONS "https://easysh-production-up.railway.app/api/generate" \
     -H "Origin: https://vakac995.github.io" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type"
```

#### B. Frontend Testing
Open browser developer tools on your GitHub Pages site and run:
```javascript
// Test basic connectivity
fetch('https://easysh-production-up.railway.app/api/cors-test')
  .then(response => response.json())
  .then(data => console.log('CORS test:', data))
  .catch(error => console.error('CORS error:', error));
```

### 5. Common Issues and Solutions

#### Issue 1: "CORS policy has blocked the request"
**Solution**: Verify that your GitHub Pages URL is exactly listed in the `allow_origins` array.

#### Issue 2: "Preflight request doesn't pass access control check"
**Solution**: Ensure OPTIONS handlers are implemented for all endpoints.

#### Issue 3: Railway deployment fails
**Solution**: Check that `requirements.txt` includes all necessary dependencies and the root `main.py` correctly imports the backend app.

#### Issue 4: 404 errors for API endpoints
**Solution**: Verify Railway is running the correct startup command and the FastAPI app is properly imported.

### 6. Environment Variables

Set these in Railway dashboard:
- `PORT`: Usually set automatically by Railway
- `ENVIRONMENT`: `production`

### 7. Security Considerations

- Only include necessary origins in `allow_origins`
- Use HTTPS for all production URLs
- Consider implementing rate limiting
- Validate all request headers and methods

### 8. Monitoring and Debugging

#### Railway Logs
Check Railway dashboard for deployment and runtime logs.

#### Browser Developer Tools
- Network tab: Check for CORS errors
- Console: Look for JavaScript errors
- Application tab: Verify service worker (if applicable)

#### CORS Test Endpoint
Use the `/api/cors-test` endpoint to verify CORS configuration:
```javascript
const testCORS = async () => {
  try {
    const response = await fetch('https://easysh-production-up.railway.app/api/cors-test');
    const data = await response.json();
    console.log('✅ CORS working:', data);
  } catch (error) {
    console.error('❌ CORS failed:', error);
  }
};
```

## Final Checklist

- [ ] Railway `railway.toml` configured correctly
- [ ] Root `main.py` imports backend app
- [ ] Backend CORS middleware includes GitHub Pages origins
- [ ] Frontend API configuration points to Railway
- [ ] Vite config sets correct base path for GitHub Pages
- [ ] Both services deployed and accessible
- [ ] CORS test endpoint returns success
- [ ] Frontend can make API calls without errors

## Support

If you continue to experience CORS issues:
1. Check Railway deployment logs
2. Test endpoints with curl
3. Verify exact URLs match configuration
4. Check browser network tab for detailed error messages
