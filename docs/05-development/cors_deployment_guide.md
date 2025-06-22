# CORS Fix Deployment Guide

This guide provides step-by-step instructions for deploying the CORS configuration fixes to resolve GitHub Pages ↔ Railway communication issues.

## Prerequisites

- Access to Railway project dashboard
- GitHub repository with proper permissions
- Local development environment set up

## Pre-Deployment Verification

Ensure all changes are in place:

- [ ] ✅ Removed duplicate CORS headers from `railway.toml`
- [ ] ✅ Updated FastAPI CORS middleware in `backend/main.py`
- [ ] ✅ Added OPTIONS handlers for all API endpoints
- [ ] ✅ Added CORS test endpoint `/api/cors-test`
- [ ] ✅ Added frontend CORS testing utilities
- [ ] ✅ Verified GitHub Pages base path in `vite.config.ts` is `/easySH/`

## Deployment Steps

### Step 1: Deploy Backend to Railway

#### Option A: Git-based Deployment (Recommended)
```bash
# Ensure you're in the project root
cd /path/to/easySH

# Stage the changes
git add backend/main.py railway.toml

# Commit with descriptive message
git commit -m "fix: resolve CORS issues for GitHub Pages integration

- Enhanced FastAPI CORS middleware with proper origin support
- Added explicit OPTIONS handlers for preflight requests  
- Created /api/cors-test endpoint for debugging
- Removed duplicate CORS headers from railway.toml
- Added logging for better troubleshooting"

# Push to trigger Railway deployment
git push origin main
```

#### Option B: Railway CLI Deployment
```bash
# Install Railway CLI if not already installed
npm install -g @railway/cli

# Login to Railway
railway login

# Deploy from backend directory
cd backend
railway deploy
```

### Step 2: Verify Backend Deployment

#### Check Railway Dashboard
- [ ] Navigate to Railway project dashboard
- [ ] Verify deployment completed successfully
- [ ] Check logs for any startup errors

#### Test Endpoints Manually
```bash
# Test health endpoint
curl https://easysh-production-up.railway.app/

# Expected response:
# {"status":"ok","message":"Project Generation API is running."}

# Test new CORS endpoint  
curl https://easysh-production-up.railway.app/api/cors-test

# Expected response:
# {"status":"success","message":"CORS is working correctly","timestamp":"2025-06-23T00:00:00Z"}
```

#### Verify CORS Headers
```bash
# Test CORS headers with OPTIONS request
curl -X OPTIONS https://easysh-production-up.railway.app/api/generate \
  -H "Origin: https://vakac995.github.io" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v

# Look for these headers in response:
# Access-Control-Allow-Origin: https://vakac995.github.io
# Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS  
# Access-Control-Allow-Headers: [various headers]
```

### Step 3: Deploy Frontend to GitHub Pages

The frontend auto-deploys via GitHub Actions when changes are pushed to the main branch.

#### Monitor GitHub Actions
- [ ] Go to GitHub repository → Actions tab
- [ ] Wait for "Deploy Frontend to GitHub Pages" workflow to complete
- [ ] Verify build and deployment steps succeed

#### Verify Deployment
- [ ] Visit: `https://vakac995.github.io/easySH/`
- [ ] Confirm the application loads without errors
- [ ] Check that it's the updated version with CORS testing features

### Step 4: Test CORS Integration

#### Development Mode Testing
```bash
# Run frontend locally with CORS fixes
cd frontend
npm install
npm run dev

# Open http://localhost:5173
# Look for "🔧 Dev Tools" panel in top-right corner
# Click "Test CORS Connection" button
# Verify all tests pass with green checkmarks
```

#### Production Integration Testing
1. **Open Production Site**: Navigate to `https://vakac995.github.io/easySH/`

2. **Browser Developer Tools**:
   - Open DevTools (F12)
   - Go to Network tab
   - Clear any existing entries

3. **Test Project Generation**:
   - Configure a test project through the wizard
   - Click "Generate Project" 
   - Monitor Network tab for requests

4. **Verify Success Indicators**:
   - [ ] No CORS errors in Console tab
   - [ ] OPTIONS requests return 200 status
   - [ ] POST request to `/api/generate` succeeds
   - [ ] Project ZIP file downloads successfully

### Step 5: Cross-Browser Testing

Test in multiple browsers to ensure compatibility:

#### Chrome/Chromium
- [ ] Load `https://vakac995.github.io/easySH/`
- [ ] Generate test project
- [ ] Verify download works

#### Firefox  
- [ ] Repeat same tests
- [ ] Check for any Firefox-specific CORS behaviors

#### Safari (if available)
- [ ] Test on macOS/iOS Safari
- [ ] Verify WebKit compatibility

#### Edge
- [ ] Test on Windows Edge
- [ ] Confirm Chromium-based Edge works

## Troubleshooting Common Issues

### Issue: "CORS policy" errors still appearing

**Symptoms**: Browser console shows blocked fetch requests

**Solutions**:
1. **Verify Railway Deployment**: 
   ```bash
   # Check if new backend is deployed
   curl https://easysh-production-up.railway.app/api/cors-test
   ```

2. **Check GitHub Pages URL**:
   - Confirm you're accessing `https://vakac995.github.io/easySH/` (with `/easySH/`)
   - Not just `https://vakac995.github.io`

3. **Clear Browser Cache**: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)

### Issue: OPTIONS requests failing (405 Method Not Allowed)

**Cause**: OPTIONS handlers not properly deployed

**Solution**:
```bash
# Test OPTIONS endpoint directly
curl -X OPTIONS https://easysh-production-up.railway.app/api/generate -v

# Should return 200, not 405
```

### Issue: Railway deployment fails

**Symptoms**: Railway shows build/deployment errors

**Solutions**:
1. **Check Python Dependencies**: Ensure `requirements.txt` is up to date
2. **Review Railway Logs**: Look for specific error messages
3. **Verify File Structure**: Ensure `backend/main.py` is in correct location

### Issue: GitHub Pages not updating

**Symptoms**: Old version still visible on GitHub Pages

**Solutions**:
1. **Check GitHub Actions**: Ensure workflow completed successfully
2. **Clear CDN Cache**: GitHub Pages uses CDN, may need time to propagate
3. **Force Refresh**: Clear browser cache and force reload

## Rollback Plan

If critical issues arise:

### Quick Rollback - Backend Only
```python
# Temporarily in backend/main.py, change CORS to:
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins temporarily
    allow_credentials=False,  # Must be False when using wildcard
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Full Rollback
```bash
# Revert to previous commit
git log --oneline  # Find previous commit hash
git revert <commit-hash>
git push origin main
```

## Success Verification Checklist

Mark each item as complete:

- [ ] ✅ Railway backend deployed successfully
- [ ] ✅ GitHub Pages frontend deployed successfully  
- [ ] ✅ `/api/cors-test` endpoint returns success
- [ ] ✅ No CORS errors in browser console
- [ ] ✅ Project generation works end-to-end
- [ ] ✅ ZIP download completes successfully
- [ ] ✅ Multiple browsers tested successfully
- [ ] ✅ Development mode CORS test passes

## Post-Deployment Actions

### Update Team
- [ ] Notify team of successful CORS fix deployment
- [ ] Share testing results and any observations
- [ ] Update project documentation if needed

### Monitor for Issues
- [ ] Check Railway logs for any unexpected errors
- [ ] Monitor user feedback for CORS-related problems
- [ ] Keep an eye on GitHub Actions for frontend deployment issues

### Archive Documentation
- [ ] Move this checklist to completed deployments
- [ ] Update main project documentation with CORS fix reference

---

**Deployment Completed**: ___________  
**Deployed By**: ___________  
**Verification Status**: ___________
