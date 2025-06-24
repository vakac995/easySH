// API Configuration
const config = {
  development: {
    apiBaseUrl: 'http://localhost:8000',
  },
  production: {
    // For GitHub Pages deployment with VS Code port forwarding backend
    // Replace this URL with your actual VS Code port forwarding URL
    apiBaseUrl: 'https://gtd22jfq-8000.euw.devtunnels.ms',
    // Alternative: Use Railway if port forwarding doesn't work
    // apiBaseUrl: 'https://easysh-production-up.railway.app',
  },
};

const environment = import.meta.env.MODE || 'development';
export const API_BASE_URL = config[environment].apiBaseUrl;

export default config;
