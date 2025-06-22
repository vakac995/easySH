import { API_BASE_URL } from '../config/api.js';

/**
 * Test CORS connectivity to the backend API
 * @returns {Promise<Object>} Test results
 */
export async function testCORS() {
  const results = {
    healthCheck: null,
    corsTest: null,
    errors: []
  };

  try {
    // Test basic health check
    console.log('Testing basic health check...');
    const healthResponse = await fetch(`${API_BASE_URL}/`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    if (healthResponse.ok) {
      results.healthCheck = await healthResponse.json();
      console.log('✅ Health check passed:', results.healthCheck);
    } else {
      throw new Error(`Health check failed: ${healthResponse.status} ${healthResponse.statusText}`);
    }
  } catch (error) {
    console.error('❌ Health check failed:', error);
    results.errors.push(`Health check: ${error.message}`);
  }

  try {
    // Test CORS-specific endpoint
    console.log('Testing CORS endpoint...');
    const corsResponse = await fetch(`${API_BASE_URL}/api/cors-test`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    if (corsResponse.ok) {
      results.corsTest = await corsResponse.json();
      console.log('✅ CORS test passed:', results.corsTest);
    } else {
      throw new Error(`CORS test failed: ${corsResponse.status} ${corsResponse.statusText}`);
    }
  } catch (error) {
    console.error('❌ CORS test failed:', error);
    results.errors.push(`CORS test: ${error.message}`);
  }

  return results;
}

/**
 * Test the main generate API endpoint
 * @param {Object} config - Test configuration
 * @returns {Promise<Object>} Test results
 */
export async function testGenerateAPI(config = null) {
  const testConfig = config || {
    global: {
      projectName: "cors-test-project"
    },
    backend: {
      include: true,
      projectName: "test-backend",
      projectDescription: "Test backend for CORS",
      dbName: "test_db",
      dbUser: "test_user"
    },
    frontend: {
      include: false
    }
  };

  try {
    console.log('Testing generate API...');
    const response = await fetch(`${API_BASE_URL}/api/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(testConfig)
    });

    if (response.ok) {
      const blob = await response.blob();
      console.log('✅ Generate API test passed, received blob of size:', blob.size);
      return { 
        success: true, 
        size: blob.size,
        contentType: response.headers.get('Content-Type')
      };
    } else {
      const errorText = await response.text();
      throw new Error(`Generate API failed: ${response.status} ${response.statusText} - ${errorText}`);
    }
  } catch (error) {
    console.error('❌ Generate API test failed:', error);
    return { 
      success: false, 
      error: error.message 
    };
  }
}

/**
 * Run all CORS tests
 * @returns {Promise<Object>} Complete test results
 */
export async function runAllCORSTests() {
  console.log('🚀 Starting CORS connectivity tests...');
  console.log('API Base URL:', API_BASE_URL);
  
  const corsResults = await testCORS();
  const generateResults = await testGenerateAPI();
  
  const allResults = {
    apiBaseUrl: API_BASE_URL,
    corsTests: corsResults,
    generateTest: generateResults,
    overallSuccess: corsResults.errors.length === 0 && generateResults.success
  };
  
  console.log('📊 Complete test results:', allResults);
  return allResults;
}
