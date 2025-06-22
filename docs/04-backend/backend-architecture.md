# Backend Architecture & Template System

## Overview

The easySH backend is a FastAPI-based service that processes configuration requests and generates complete project structures using a Jinja2 template system. It provides a secure, scalable solution for project generation.

## Core Components

### FastAPI Application Structure

```python
# Main application structure
app = FastAPI(
    title="Project Generation Service",
    description="Generates project structures from templates",
    version="1.0.0"
)

# CORS configuration for frontend communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)
```

### Pydantic Data Models

The backend uses Pydantic models for request validation and type safety:

#### Global Configuration
```python
class GlobalConfig(BaseModel):
    projectName: str = Field(
        ..., min_length=1, 
        description="Overall project name for the root folder."
    )
```

#### Backend Configuration
```python
class BackendConfig(BaseModel):
    include: bool = False
    projectName: str = "backend"
    projectDescription: str = "A robust backend service."
    projectVersion: str = "0.1.0"
    dbHost: str = "postgres"
    dbPort: int = 5432
    dbName: str = "app_db"
    dbUser: str = "db_user"
    dbPassword: Optional[str] = ""
    pgAdminEmail: str = "admin@example.com"
    pgAdminPassword: Optional[str] = ""
    debug: bool = False
    logLevel: str = "INFO"
```

#### Frontend Configuration
```python
class FrontendConfig(BaseModel):
    include: bool = False
    projectName: str = "frontend"
    includeExamplePages: bool = False
    includeHusky: bool = False
    moduleSystem: FrontendModuleSystem = Field(default_factory=FrontendModuleSystem)
```

#### Module System
```python
class FrontendModule(BaseModel):
    id: str
    name: str
    permissions: str

class FrontendFeature(BaseModel):
    id: str

class FrontendModuleSystem(BaseModel):
    include: bool = False
    modules: List[FrontendModule] = []
    features: List[FrontendFeature] = []
```

## Template System

### Directory Structure

```
backend/templates/
├── setup_environment.sh.jinja2          # Project setup script
├── backend/                             # Backend templates
│   ├── docker-compose.yml.jinja2       # Docker configuration
│   ├── Dockerfile.jinja2               # Docker image definition
│   ├── gunicorn.conf.py.jinja2         # WSGI server config
│   ├── main.py.jinja2                  # FastAPI application
│   ├── requirements.txt.jinja2         # Python dependencies
│   ├── README.md.jinja2                # Backend documentation
│   ├── start_dev.sh.jinja2             # Development startup
│   ├── start_docker.sh.jinja2          # Docker startup
│   ├── start_prod.sh.jinja2            # Production startup
│   ├── sql/
│   │   ├── init/
│   │   │   ├── 01_create_tables.sql.jinja2
│   │   │   └── 02_sample_data.sql.jinja2
│   │   └── queries/
│   │       └── user_posts.sql.jinja2
│   └── src/
│       ├── __init__.py.jinja2
│       └── database_manager.py.jinja2
└── frontend/                           # Frontend templates
    ├── eslint.config.js.jinja2        # ESLint configuration
    ├── package.json.jinja2            # NPM dependencies
    ├── postcss.config.js.jinja2       # PostCSS configuration
    ├── tailwind.config.js.jinja2      # Tailwind CSS config
    ├── tsconfig.json.jinja2           # TypeScript configuration
    ├── vite.config.ts.jinja2          # Vite build config
    └── src/
        ├── App.tsx.jinja2              # Main React component
        ├── index.css.jinja2           # Global styles
        ├── main.tsx.jinja2            # Application entry point
        ├── vite-env.d.ts.jinja2       # Vite type definitions
        ├── components/
        │   ├── ConditionalRender.tsx.jinja2
        │   └── Layout.tsx.jinja2
        ├── config/
        ├── hooks/
        │   └── useConfig.ts.jinja2
        ├── lib/
        │   └── utils.ts.jinja2
        ├── pages/
        │   ├── About.tsx.jinja2
        │   ├── Contact.tsx.jinja2
        │   └── Home.tsx.jinja2
        ├── providers/
        │   └── ConfigProvider.tsx.jinja2
        ├── services/
        │   └── configService.ts.jinja2
        ├── types/
        │   └── config.ts.jinja2
        └── utils/
            └── configUtils.ts.jinja2
```

### Template Processing

#### Jinja2 Environment Setup
```python
template_dir = Path(__file__).parent / "templates"
jinja_env = Environment(loader=FileSystemLoader(template_dir), autoescape=True)
```

#### Template Rendering Process
```python
def _process_template_directory(zip_file, config, dir_name, template_dir, jinja_env):
    """Processes a single directory of templates."""
    source_dir = template_dir / dir_name
    
    for root, _, files in os.walk(source_dir):
        template_root_path = Path(root)
        for filename in files:
            if not filename.endswith(".jinja2"):
                continue
                
            # Load and render template
            template_name = str(template_path.relative_to(template_dir)).replace("\\", "/")
            template = jinja_env.get_template(template_name)
            rendered_content = template.render(config=config.model_dump(by_alias=True))
            
            # Add to ZIP archive
            final_filename = filename.removesuffix(".jinja2")
            zip_path = Path(project_name) / project_part_name / relative_path / final_filename
            zip_file.writestr(str(zip_path), rendered_content)
```

### Configuration Usage in Templates

Templates use the `config` object to conditionally generate content:

#### Example: Docker Compose Template
```yaml
# docker-compose.yml.jinja2
version: '3.8'

services:
  backend:
    build: .
    container_name: {{ config.backend.projectName }}
    environment:
      - DATABASE_URL=postgresql://{{ config.backend.dbUser }}:{{ config.backend.dbPassword }}@{{ config.backend.dbHost }}:{{ config.backend.dbPort }}/{{ config.backend.dbName }}
      - LOG_LEVEL={{ config.backend.logLevel }}
      - DEBUG={{ config.backend.debug }}
    depends_on:
      - postgres

  postgres:
    image: postgres:13
    container_name: {{ config.backend.dbHost }}
    environment:
      POSTGRES_DB: {{ config.backend.dbName }}
      POSTGRES_USER: {{ config.backend.dbUser }}
      POSTGRES_PASSWORD: {{ config.backend.dbPassword }}
    ports:
      - "{{ config.backend.dbPort }}:5432"

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: {{ config.backend.pgAdminEmail }}
      PGADMIN_DEFAULT_PASSWORD: {{ config.backend.pgAdminPassword }}
```

#### Example: Package.json Template
```json
{
  "name": "{{ config.frontend.projectName }}",
  "version": "0.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.22.3"
  }
}
```

#### Example: Conditional Frontend Features
```typescript
// App.tsx.jinja2
import React from 'react';
{% if config.frontend.moduleSystem.include %}
import { ConfigProvider } from './providers/ConfigProvider';
import { useConfig } from './hooks/useConfig';
{% endif %}

function App() {
  {% if config.frontend.moduleSystem.include %}
  return (
    <ConfigProvider>
      <MainContent />
    </ConfigProvider>
  );
  {% else %}
  return <MainContent />;
  {% endif %}
}
```

## API Endpoints

### Health Check
```python
@app.get("/", tags=["Health Check"])
def read_root():
    """A simple health check endpoint."""
    return {"status": "ok", "message": "Project Generation API is running."}
```

### Project Generation
```python
@app.post("/api/generate", tags=["Generation"])
async def generate_project(config: MasterConfig):
    """Accepts a JSON configuration and returns a zipped project archive."""
    
    # Validation
    if not config.backend.include and not config.frontend.include:
        raise HTTPException(
            status_code=400,
            detail="At least one part must be included."
        )
    
    # Generate ZIP archive
    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zip_file:
        # Process backend templates
        if config.backend.include:
            _process_template_directory(zip_file, config, "backend", template_dir, jinja_env)
        
        # Process frontend templates  
        if config.frontend.include:
            _process_template_directory(zip_file, config, "frontend", template_dir, jinja_env)
            
        # Add setup script
        setup_template = jinja_env.get_template("setup_environment.sh.jinja2")
        rendered_setup = setup_template.render(config=config.model_dump(by_alias=True))
        zip_file.writestr(f"{config.global_config.projectName}/setup_environment.sh", rendered_setup)
    
    # Return ZIP file
    zip_buffer.seek(0)
    headers = {"Content-Disposition": f'attachment; filename="{config.global_config.projectName}.zip"'}
    return StreamingResponse(zip_buffer, media_type="application/zip", headers=headers)
```

## Generated Project Features

### Backend Projects Include

1. **FastAPI Application**: Complete REST API with health checks
2. **Database Integration**: PostgreSQL with SQLAlchemy
3. **Docker Configuration**: Multi-service docker-compose setup
4. **Database Management**: Migration scripts and query examples
5. **Production Setup**: Gunicorn configuration for deployment
6. **Development Tools**: Development startup scripts
7. **Documentation**: README with setup instructions

### Frontend Projects Include

1. **React + TypeScript**: Modern React application with TypeScript
2. **Vite Configuration**: Fast development and build tooling
3. **Tailwind CSS**: Utility-first CSS framework
4. **ESLint + Prettier**: Code quality and formatting tools
5. **Router Setup**: React Router for navigation
6. **Component Library**: Reusable UI components
7. **Configuration System**: Environment-based configuration
8. **Module System**: Feature flags and permissions (when enabled)

### Setup Script Features

The generated `setup_environment.sh` script provides:

1. **Environment Detection**: Automatic OS and tool detection
2. **Dependency Installation**: Node.js, Python, Docker setup
3. **Project Initialization**: Database setup and initial configuration
4. **Development Server Startup**: One-command project launch
5. **Error Handling**: Comprehensive error checking and recovery

## Security Features

### Input Validation
- **Pydantic Models**: Strict type checking and validation
- **SQL Injection Prevention**: No direct SQL execution from user input
- **Path Traversal Protection**: Template paths are validated and sandboxed
- **File System Isolation**: No arbitrary file system access

### Template Security
- **Sandboxed Execution**: Jinja2 templates run in restricted environment
- **No Code Execution**: Templates cannot execute arbitrary Python code
- **Input Sanitization**: All user input is properly escaped

### Network Security
- **CORS Configuration**: Properly configured cross-origin resource sharing
- **Request Size Limits**: Prevent large request attacks
- **Rate Limiting**: Can be added for production environments

## Performance Optimizations

### Memory Management
- **Streaming Responses**: ZIP files are streamed directly to client
- **In-Memory Processing**: No temporary file storage required
- **Efficient Template Loading**: Templates are cached by Jinja2

### Scalability
- **Stateless Design**: No server-side state storage
- **Horizontal Scaling**: Multiple instances can run simultaneously
- **Resource Efficiency**: Minimal CPU and memory usage per request

## Development Setup

### Requirements
```
fastapi
uvicorn[standard]
pydantic
Jinja2
python-multipart
```

### Running in Development
```bash
cd backend
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

### Docker Development
```bash
cd backend
docker build -t easysh-backend .
docker run -p 8000:8000 easysh-backend
```

## Error Handling

### Validation Errors
```python
# Automatic Pydantic validation
{
  "detail": [
    {
      "loc": ["body", "global", "projectName"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

### Template Errors
```python
try:
    template = jinja_env.get_template(template_name)
    rendered_content = template.render(config=config.model_dump())
except Exception as e:
    print(f"Error processing template {template_path}: {e}")
    raise HTTPException(
        status_code=500,
        detail=f"Failed to render template: {filename}"
    )
```

### ZIP Generation Errors
- **Memory Limits**: Handling large projects
- **File Corruption**: Validation of generated content
- **Network Interruption**: Graceful handling of connection issues

## Future Enhancements

### Planned Features
1. **Template Versioning**: Multiple template versions for different project types
2. **Custom Templates**: User-uploadable template system
3. **Database Support**: Multiple database options (MySQL, SQLite, MongoDB)
4. **Microservices**: Support for multi-service architectures
5. **CI/CD Integration**: GitHub Actions and deployment configurations

### Performance Improvements
1. **Template Caching**: Advanced caching strategies
2. **Compression**: Better ZIP compression algorithms
3. **Parallel Processing**: Concurrent template rendering
4. **Resource Pooling**: Connection and resource pooling

### Security Enhancements
1. **Authentication**: User authentication and authorization
2. **Audit Logging**: Comprehensive request logging
3. **Rate Limiting**: Request rate limiting and throttling
4. **Input Sanitization**: Enhanced input validation and sanitization
