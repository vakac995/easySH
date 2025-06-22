# EasySH API Testing Suite

This directory contains a comprehensive Postman collection and testing suite for the EasySH Project Generation API. The suite includes tests for development and production environments, error handling, performance testing, and load testing.

## 📁 Files Overview

- `EasySH-API-Collection.json` - Main Postman collection with all API tests
- `EasySH-Development.postman_environment.json` - Development environment variables
- `EasySH-Production.postman_environment.json` - Production environment variables
- `run-tests.sh` - Automated test runner script
- `README.md` - This documentation file

## 🚀 Quick Start

### Prerequisites

1. **Postman Extension**: Already installed in VS Code
2. **Newman (Optional)**: For command-line testing
   ```bash
   npm install -g newman
   npm install -g newman-reporter-htmlextra
   ```

### Using Postman Extension in VS Code

1. Open the Command Palette (`Ctrl+Shift+P`)
2. Search for "Postman" commands
3. Import the collection and environment files
4. Start testing your API directly in VS Code

### Using Newman (Command Line)

```bash
# Navigate to the postman-collections directory
cd postman-collections

# Make the test runner executable
chmod +x run-tests.sh

# Run tests
./run-tests.sh dev      # Development tests
./run-tests.sh prod     # Production tests
./run-tests.sh all      # All tests
./run-tests.sh health   # Health check only
```

## 🧪 Test Categories

### 1. Health Check & CORS
- **Root Health Check**: Verifies API is running
- **CORS Test**: Validates cross-origin request handling
- **CORS Preflight**: Tests OPTIONS requests for complex requests

### 2. Project Generation
- **Backend Only**: Tests generating backend-only projects
- **Frontend Only**: Tests generating frontend-only projects
- **Full Stack**: Tests complete project generation with both components

### 3. Error Handling
- **No Components Selected**: Tests validation when neither backend nor frontend is included
- **Invalid JSON**: Tests validation error responses
- **Malformed JSON**: Tests malformed request handling

### 4. Performance Tests
- **Large Project Generation**: Tests with complex configurations and many modules
- **Response Time Validation**: Ensures reasonable response times

### 5. Load Testing
- **Concurrent Requests**: Tests multiple simultaneous requests
- **Iteration Testing**: Runs multiple test cycles

## 🔧 Environment Configuration

### Development Environment
- **Base URL**: `http://localhost:8000`
- **Frontend Origin**: `http://localhost:5173`
- **Environment**: `development`

### Production Environment
- **Base URL**: `https://your-railway-app.railway.app` (Update with your actual URL)
- **Frontend Origin**: `https://vakac995.github.io`
- **Environment**: `production`

## 📊 Test Assertions

Each test includes comprehensive assertions:

### Success Criteria
- ✅ **Status Code**: Correct HTTP status codes (200, 400, 422, etc.)
- ✅ **Response Headers**: Proper content types and CORS headers
- ✅ **Response Body**: Valid JSON structure and expected data
- ✅ **File Download**: Zip file generation and proper headers
- ✅ **Performance**: Response time within acceptable limits

### Error Handling
- ❌ **Validation Errors**: Proper error messages for invalid input
- ❌ **Missing Data**: Appropriate responses for incomplete requests
- ❌ **Server Errors**: Graceful handling of server-side issues

## 🎯 Sample Test Requests

### Basic Backend Project
```json
{
  "global": {
    "projectName": "TestBackendOnly"
  },
  "backend": {
    "include": true,
    "projectName": "api-service",
    "projectDescription": "Backend API Service",
    "projectVersion": "1.0.0",
    "dbHost": "localhost",
    "dbPort": 5432,
    "dbName": "test_db",
    "dbUser": "test_user",
    "dbPassword": "test_pass",
    "debug": true,
    "logLevel": "DEBUG"
  },
  "frontend": {
    "include": false
  }
}
```

### Full Stack Project with Modules
```json
{
  "global": {
    "projectName": "FullStackProject"
  },
  "backend": {
    "include": true,
    "projectName": "backend",
    "projectDescription": "Full Stack Backend Service",
    "projectVersion": "2.0.0"
  },
  "frontend": {
    "include": true,
    "projectName": "frontend",
    "includeExamplePages": true,
    "includeHusky": true,
    "moduleSystem": {
      "include": true,
      "modules": [
        {
          "id": "auth",
          "name": "Authentication",
          "permissions": "admin"
        },
        {
          "id": "dashboard",
          "name": "Dashboard",
          "permissions": "user"
        }
      ],
      "features": [
        {
          "id": "dark-mode"
        },
        {
          "id": "notifications"
        }
      ]
    }
  }
}
```

## 🔄 CI/CD Integration

The test suite is designed for integration with CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run API Tests
  run: |
    cd postman-collections
    ./run-tests.sh all
```

## 📈 Performance Benchmarks

### Expected Performance
- **Simple Project Generation**: < 5 seconds
- **Complex Full Stack Project**: < 15 seconds
- **Large Project with Many Modules**: < 30 seconds

### Load Testing
- **Concurrent Requests**: 5 iterations with 100ms delay
- **Success Rate**: > 95%
- **Average Response Time**: < 10 seconds

## 🛠️ Customization

### Adding New Tests
1. Open the collection in Postman
2. Add new requests to appropriate folders
3. Include test scripts with assertions
4. Export and update the collection file

### Environment Variables
Update environment files to match your deployment:

```json
{
  "key": "base_url",
  "value": "https://your-actual-domain.com",
  "type": "default",
  "enabled": true
}
```

### Custom Test Scripts
Example test script for new endpoints:

```javascript
pm.test('Status code is 200', function () {
    pm.response.to.have.status(200);
});

pm.test('Response contains expected data', function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('status');
    pm.expect(jsonData.status).to.eql('success');
});

pm.test('Response time is acceptable', function () {
    pm.expect(pm.response.responseTime).to.be.below(5000);
});
```

## 🚨 Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure the development server is running
   - Check if the port is correct (8000 for backend)

2. **CORS Errors**
   - Verify origin headers in requests
   - Check CORS configuration in FastAPI

3. **Timeout Errors**
   - Increase timeout values in Newman
   - Check server performance and resources

4. **File Download Issues**
   - Verify Content-Disposition headers
   - Check zip file generation in backend

### Debug Mode
Run tests with verbose output:

```bash
newman run EasySH-API-Collection.json \
    -e EasySH-Development.postman_environment.json \
    --verbose \
    --debug
```

## 📝 Reporting

Test results are automatically generated in multiple formats:

- **HTML Report**: `test-results/report-{env}.html` - Visual test results
- **JSON Report**: `test-results/results-{env}.json` - Machine-readable results
- **CLI Output**: Real-time test execution feedback

## 🤝 Contributing

When adding new API endpoints:

1. Add corresponding tests to the collection
2. Update environment variables if needed
3. Add assertions for success and error cases
4. Update this documentation
5. Test with both development and production environments

## 📞 Support

For issues or questions about the API testing suite:

1. Check the test results and error messages
2. Verify environment configuration
3. Review API endpoint documentation
4. Check server logs for backend issues

---

Happy Testing! 🎉
