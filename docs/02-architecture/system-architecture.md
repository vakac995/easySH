# System Architecture

## Overview

easySH follows a modern, decoupled architecture that separates concerns between the user interface, business logic, and template processing. This design ensures scalability, maintainability, and security.

## High-Level Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   React Client  │     │  FastAPI Server │     │     Templates   │
│                 │     │                 │     │                 │
│ - Wizard UI     │◄───►│ - REST API      │────►│ - Jinja2 Files  │
│ - Gamification  │     │ - Validation    │     │ - Project Files │
│ - Configuration │     │ - Generation    │     │ - Setup Scripts │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Component Details

### 1. Frontend (React Application)

**Location**: `frontend/`

The frontend is a single-page application (SPA) built with React and Vite. It provides an interactive wizard interface for users to configure their projects.

**Key Components**:

- **Wizard System**: Multi-step form with progress tracking
- **Gamification Engine**: Achievements, power levels, and celebration animations
- **Configuration Management**: State management for project settings
- **API Client**: Handles communication with the backend

**Technology Stack**:

- React 18 with hooks and context
- Vite for development and build tooling
- Tailwind CSS for styling
- Framer Motion for animations
- PropTypes for runtime type checking

### 2. Backend (FastAPI Service)

**Location**: `backend/`

The backend is a RESTful API service that processes configuration requests and generates project files using templates.

**Key Components**:

- **REST API**: Endpoints for project generation and health checks
- **Template Engine**: Jinja2-based file generation system
- **Validation Layer**: Pydantic models for request validation
- **File Processing**: ZIP archive creation and streaming

**Technology Stack**:

- FastAPI for high-performance API development
- Pydantic for data validation and serialization
- Jinja2 for template rendering
- Python standard library for file operations

### 3. Template System

**Location**: `backend/templates/`

The template system contains Jinja2 templates that define the structure and content of generated projects.

**Structure**:

```
templates/
├── setup_environment.sh.jinja2    # Project setup script
├── backend/                       # Backend project templates
│   ├── docker-compose.yml.jinja2
│   ├── Dockerfile.jinja2
│   ├── main.py.jinja2
│   └── src/
└── frontend/                      # Frontend project templates
    ├── package.json.jinja2
    ├── vite.config.ts.jinja2
    └── src/
```

## Data Flow

### 1. Configuration Collection

1. User interacts with the React wizard
2. Configuration state is managed in the Wizard component
3. Each step validates and updates the configuration object
4. Final configuration is reviewed before submission

### 2. Project Generation Request

```
Frontend ──[POST /api/generate]──► Backend
         {
           "global": {
             "projectName": "..."
           },
           "backend": {...},
           "frontend": {...}
         }
```

### 3. Template Processing

1. Backend validates the configuration using Pydantic models
2. Jinja2 environment loads templates from the templates directory
3. Each template is rendered with the provided configuration
4. Generated files are collected in memory

### 4. Archive Creation

1. All generated files are packaged into a ZIP archive
2. The archive is created in memory to avoid disk I/O
3. Archive is streamed back to the client

### 5. Download Delivery

```
Backend ──[ZIP Stream]──► Frontend ──[File Download]──► User
```

## Security Considerations

### Input Validation

- All user input is validated using Pydantic models
- Template rendering is isolated and sandboxed
- No arbitrary code execution is possible

### File System Protection

- Templates are read-only
- No direct file system access from user input
- Generated files exist only in memory

### Network Security

- CORS is properly configured for frontend-backend communication
- No sensitive data is logged or exposed
- All communication uses standard HTTP/HTTPS

## Scalability Features

### Stateless Design

- No server-side session storage
- Each request is independent
- Easy to horizontally scale

### Memory Efficiency

- ZIP files are created in memory
- No temporary file storage required
- Efficient template caching

### Template Extensibility

- Easy to add new project types
- Configuration schema can be extended
- Templates can include conditional logic

## Development vs. Production

### Development Mode

- Frontend: Vite dev server on port 5173
- Backend: Uvicorn with auto-reload on port 8000
- CORS enabled for localhost
- Detailed error messages and logging

### Production Mode

- Frontend: Static files served by web server
- Backend: Gunicorn with multiple workers
- Proper CORS configuration
- Security headers and error handling
- Docker containers for deployment

## Error Handling

### Frontend

- User-friendly error messages
- Fallback UI states
- Network error recovery
- Form validation feedback

### Backend

- Structured error responses
- Request validation errors
- Template rendering error handling
- Comprehensive logging

## Monitoring and Observability

### Health Checks

- Backend exposes health check endpoint at `/`
- Frontend can detect backend availability
- Docker containers include health checks

### Logging

- Structured logging with appropriate levels
- Request/response logging for debugging
- Error tracking and reporting
- Performance metrics collection
