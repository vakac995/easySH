// API Configuration
const config = {
  development: {
    apiBaseUrl: 'http://localhost:8000',
  },
  production: {
    apiBaseUrl: 'https://easysH-production-up.railway.app',
  },
};

const environment = import.meta.env.MODE || 'development';
export const API_BASE_URL = config[environment].apiBaseUrl;

export default config;
