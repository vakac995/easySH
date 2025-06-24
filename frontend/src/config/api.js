// API Configuration
const config = {
  development: {
    apiBaseUrl: import.meta.env.VITE_API_BASE_URL_DEV || 'http://localhost:8000',
  },
  production: {
    // Use environment variable from GitHub secrets for production
    apiBaseUrl: import.meta.env.VITE_API_BASE_URL_PROD || 'https://easysh-production-up.railway.app',
  },
};

const environment = import.meta.env.MODE || 'development';
export const API_BASE_URL = config[environment].apiBaseUrl;

// Log the configuration for debugging (only in development)
if (environment === 'development') {
  console.log('🔧 API Configuration:', {
    environment,
    apiBaseUrl: API_BASE_URL,
  });
}

export default config;
