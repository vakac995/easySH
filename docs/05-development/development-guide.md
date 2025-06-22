# Development Guide

## Prerequisites

Before setting up the development environment, ensure you have the following installed:

- **Node.js 18+**: For frontend development
- **Python 3.8+**: For backend development
- **Git**: For version control
- **Docker & Docker Compose**: For containerized development (optional)

## Project Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd easySH
```

### 2. Backend Setup

#### Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

#### Start the Backend Server

```bash
# Development mode with auto-reload
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000

# Or using the provided script
./start_dev.sh
```

The backend will be available at `http://localhost:8000`

#### API Documentation

FastAPI automatically generates interactive API documentation:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### 3. Frontend Setup

#### Install Node Dependencies

```bash
cd frontend
npm install
```

#### Start the Frontend Development Server

```bash
npm run dev
```

The frontend will be available at `http://localhost:5173`

### 4. Verify Setup

1. Open `http://localhost:5173` in the browser
2. Complete the wizard with sample data
3. Generate a test project
4. Verify the downloaded ZIP contains the expected files

## Development Workflow

### Frontend Development

#### Component Development
1. Create new components in `frontend/src/components/`
2. Use functional components with React hooks
3. Add PropTypes for type checking
4. Style with Tailwind CSS utility classes
5. Add animations with Framer Motion

#### State Management
- Use `useState` for local component state
- Use `useEffect` for side effects and lifecycle
- Use `useCallback` for memoized event handlers
- Pass state down through props or context

#### Code Style
```bash
# Format code
npm run format

# Lint code
npm run lint

# Type checking (if using TypeScript)
npm run type-check
```

### Backend Development

#### Adding New Templates
1. Create `.jinja2` files in `backend/templates/`
2. Use the `config` object for dynamic content
3. Test with different configuration combinations
4. Update Pydantic models if new config fields are needed

#### API Development
1. Add new endpoints to `main.py`
2. Use Pydantic models for request/response validation
3. Add appropriate error handling
4. Test with curl or the interactive docs

#### Code Style
```bash
# Format code (if using black)
black main.py

# Type checking (if using mypy)
mypy main.py
```

## Testing

### Frontend Testing

#### Manual Testing Checklist
- [ ] All wizard steps load correctly
- [ ] Form validation works as expected
- [ ] Gamification features trigger properly
- [ ] Project generation downloads successfully
- [ ] Mobile responsiveness works
- [ ] Dark mode functions correctly

#### Automated Testing (Future)
```bash
# Unit tests
npm run test

# End-to-end tests
npm run test:e2e
```

### Backend Testing

#### Manual Testing
```bash
# Health check
curl http://localhost:8000/

# Test project generation
curl -X POST "http://localhost:8000/api/generate" \
  -H "Content-Type: application/json" \
  -d '{"global":{"projectName":"test"},"backend":{"include":true},"frontend":{"include":true}}' \
  -o test-project.zip
```

#### Automated Testing (Future)
```bash
# Unit tests
pytest

# Integration tests
pytest tests/integration/
```

## Environment Configuration

### Development Environment Variables

#### Backend (.env)
```bash
DEBUG=true
LOG_LEVEL=INFO
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
```

#### Frontend (.env.local)
```bash
VITE_API_URL=http://localhost:8000
```

### Production Considerations

#### Backend
- Use environment variables for sensitive configuration
- Enable HTTPS and proper CORS settings
- Configure logging and monitoring
- Use production WSGI server (Gunicorn)

#### Frontend
- Build for production: `npm run build`
- Serve static files with web server (Nginx, Apache)
- Configure proper cache headers
- Enable gzip compression

## Debugging

### Frontend Debugging

#### Browser DevTools
- Use React Developer Tools extension
- Check Network tab for API requests
- Monitor Console for JavaScript errors
- Use Sources tab for breakpoint debugging

#### Common Issues
1. **API connection errors**: Check backend server status
2. **CORS errors**: Verify backend CORS configuration
3. **Component re-render issues**: Use React DevTools Profiler
4. **State update problems**: Check for immutability violations

### Backend Debugging

#### Logging
```python
import logging
logger = logging.getLogger(__name__)

# Add debug logs
logger.debug(f"Processing config: {config}")
logger.info(f"Generated files for project: {project_name}")
```

#### Common Issues
1. **Template rendering errors**: Check Jinja2 syntax and config object
2. **ZIP generation failures**: Verify file paths and permissions
3. **Pydantic validation errors**: Check request payload structure
4. **Memory issues**: Monitor memory usage for large projects

## Docker Development

### Using Docker Compose

```bash
# Start all services
docker-compose up --build

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Development with Docker

#### Backend Only
```bash
cd backend
docker build -t easysh-backend .
docker run -p 8000:8000 -v $(pwd):/app easysh-backend
```

#### Frontend Only
```bash
cd frontend
docker build -t easysh-frontend .
docker run -p 5173:5173 -v $(pwd)/src:/app/src easysh-frontend
```

## IDE Configuration

### VS Code Recommended Extensions

#### Frontend
- ES7+ React/Redux/React-Native snippets
- Prettier - Code formatter
- ESLint
- Tailwind CSS IntelliSense
- Auto Rename Tag

#### Backend
- Python
- Pylance
- Python Docstring Generator
- autoDocstring
- Better Jinja

### VS Code Settings
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "python.defaultInterpreterPath": "./venv/bin/python",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true
}
```

## Performance Optimization

### Frontend Performance

#### Bundle Analysis
```bash
# Analyze bundle size
npm run build
npx vite-bundle-analyzer dist
```

#### Optimization Techniques
- Use `React.memo` for expensive components
- Implement `useCallback` and `useMemo` appropriately
- Code splitting with dynamic imports
- Optimize images and assets
- Use service workers for caching

### Backend Performance

#### Profiling
```python
import cProfile
import pstats

def profile_endpoint():
    profiler = cProfile.Profile()
    profiler.enable()
    
    # Your endpoint logic here
    
    profiler.disable()
    stats = pstats.Stats(profiler)
    stats.sort_stats('cumulative')
    stats.print_stats()
```

#### Optimization Techniques
- Use async/await for I/O operations
- Implement response caching
- Optimize template rendering
- Use connection pooling
- Monitor memory usage

## Deployment

### Frontend Deployment

#### Build for Production
```bash
npm run build
```

#### Static File Serving
- Upload `dist/` folder to CDN or web server
- Configure proper cache headers
- Enable gzip compression
- Set up HTTPS

### Backend Deployment

#### Production Server
```bash
# Using Gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker

# Using Docker
docker build -t easysh-backend .
docker run -p 8000:8000 easysh-backend
```

#### Environment Configuration
- Set production environment variables
- Configure proper logging
- Enable monitoring and health checks
- Set up load balancing if needed

## Troubleshooting

### Common Development Issues

#### Frontend Won't Start
```bash
# Clear node modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Check Node.js version
node --version  # Should be 18+
```

#### Backend Won't Start
```bash
# Check Python version
python --version  # Should be 3.8+

# Reinstall dependencies
pip install -r requirements.txt

# Check for port conflicts
netstat -an | grep 8000
```

#### CORS Issues
- Verify backend CORS configuration in `main.py`
- Check frontend API URL configuration
- Ensure both servers are running on expected ports

#### Template Rendering Errors
- Validate Jinja2 template syntax
- Check that config object contains expected fields
- Verify file paths and directory structure

### Getting Help

1. **Check Documentation**: Review relevant documentation sections
2. **Search Issues**: Look for similar problems in project issues
3. **Enable Debug Logging**: Add debug logs to isolate problems
4. **Test in Isolation**: Test individual components separately
5. **Ask for Help**: Create detailed issue reports with reproduction steps

## Contributing

### Code Review Process
1. Create feature branch from `main`
2. Make changes with clear commit messages
3. Test changes thoroughly
4. Submit pull request with description
5. Address review feedback
6. Merge after approval

### Code Standards
- Follow existing code style and patterns
- Add appropriate comments and documentation
- Include tests for new functionality
- Update documentation for changes
- Ensure backwards compatibility
