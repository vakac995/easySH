# Port Forwarding Deployment Guide

This guide explains how to use VS Code port forwarding to test your application and deploy the frontend to GitHub Pages while keeping the backend running locally with a public port-forwarded URL.

## Overview

Instead of dealing with complex CORS configurations between Railway and GitHub Pages, we'll use VS Code's built-in port forwarding feature to make our locally running backend accessible via a public HTTPS URL.

## Step-by-Step Process

### 1. Start the Backend with Port Forwarding

1. **Run the backend startup script:**
   ```bash
   ./start_backend_with_forwarding.sh
   ```

2. **Enable port forwarding in VS Code:**
   - Open the **Ports** tab in VS Code (usually at the bottom panel)
   - You should see port 8000 listed (if not, click the "+" and add port 8000)
   - Right-click on port 8000 and select "Port Visibility" → "Public"
   - Copy the forwarded URL (it will look like `https://localhost-8000.app.github.dev`)

### 2. Update Frontend Configuration

1. **Update the production API URL:**
   - Open `frontend/src/config/api.js`
   - Replace the `apiBaseUrl` in the production config with your port-forwarded URL
   - Example:
     ```javascript
     production: {
       apiBaseUrl: 'https://localhost-8000.app.github.dev', // Your forwarded URL
     }
     ```

### 3. Test Locally First

1. **Start the frontend in development mode:**
   ```bash
   cd frontend
   npm run dev
   ```

2. **Test the connection:**
   - Open http://localhost:5173
   - Try generating a project to ensure the frontend can communicate with the backend
   - Check the browser console for any CORS errors

### 4. Build and Deploy Frontend

1. **Build the frontend for production:**
   ```bash
   cd frontend
   npm run build
   ```

2. **Deploy to GitHub Pages:**
   - The build will create a `dist` folder
   - Push the contents of `dist` to your GitHub Pages repository
   - Or use GitHub Actions for automatic deployment

### 5. Test the Deployed Frontend

1. **Access your GitHub Pages site:**
   - Go to https://vakac995.github.io/easySH/
   - Test the project generation functionality
   - The frontend should now communicate with your port-forwarded backend

## Advantages of This Approach

- ✅ **No CORS issues**: VS Code port forwarding provides proper HTTPS URLs
- ✅ **Easy debugging**: Backend runs locally, so you can debug easily
- ✅ **No deployment complexity**: Only frontend needs to be deployed
- ✅ **Real-time backend updates**: Changes to backend are immediately available
- ✅ **Cost effective**: No need to pay for backend hosting

## Important Notes

1. **Keep VS Code running**: The port forwarding only works while VS Code is open and connected
2. **URL stability**: The port-forwarded URL might change if you restart VS Code
3. **Update configuration**: When the URL changes, update `frontend/src/config/api.js`
4. **Security**: The port-forwarded URL is public but requires knowing the exact URL

## Alternative Configuration

If you want to quickly switch back to Railway for the backend, just update the `api.js` file:

```javascript
production: {
  apiBaseUrl: 'https://easysh-production-up.railway.app',
}
```

## Troubleshooting

### Port Forwarding URL Not Working
- Ensure the port is set to "Public" in VS Code
- Check that the backend is running on port 8000
- Try refreshing the port forwarding in VS Code

### CORS Errors
- Verify the backend is using the updated CORS configuration
- Check that the API URL in `api.js` matches your port-forwarded URL
- Ensure the port-forwarded URL is HTTPS

### Backend Connection Issues
- Check that the backend is running (`./start_backend_with_forwarding.sh`)
- Verify the port forwarding is active in VS Code
- Test the backend directly by visiting the port-forwarded URL in your browser

## Next Steps

1. Start the backend with the provided script
2. Configure port forwarding in VS Code
3. Update the frontend configuration with your port-forwarded URL
4. Test locally, then deploy the frontend to GitHub Pages
