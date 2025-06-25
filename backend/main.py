import os
import io
import zipfile
import logging
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse, JSONResponse, Response
from fastapi.exceptions import RequestValidationError
from pydantic import BaseModel, Field
from jinja2 import Environment, FileSystemLoader
import traceback
from typing import Callable, Any

# Configure logging with more detailed format
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class GlobalConfig(BaseModel):
    """Configuration for global project settings."""

    projectName: str = Field(
        ..., min_length=1, description="Overall project name for the root folder."
    )


class BackendModule(BaseModel):
    """Defines a module within the backend."""

    id: str
    name: str
    permissions: str


class BackendFeature(BaseModel):
    """Defines a feature flag for the backend."""

    id: str


class BackendModuleSystem(BaseModel):
    """Manages backend modules and features."""

    include: bool = False
    modules: List[BackendModule] = []
    features: List[BackendFeature] = []


class BackendConfig(BaseModel):
    """Configuration specific to the backend project."""

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


class FrontendModule(BaseModel):
    """Defines a module within the frontend."""

    id: str
    name: str
    permissions: str


class FrontendFeature(BaseModel):
    """Defines a feature flag for the frontend."""

    id: str


class FrontendModuleSystem(BaseModel):
    """Manages frontend modules and features."""

    include: bool = False
    modules: List[FrontendModule] = []
    features: List[FrontendFeature] = []


class FrontendConfig(BaseModel):
    """Configuration specific to the frontend project."""

    include: bool = False
    projectName: str = "frontend"
    projectDescription: str = "A modern frontend application."
    includeExamplePages: bool = False
    includeHusky: bool = False
    moduleSystem: FrontendModuleSystem = Field(default_factory=FrontendModuleSystem)


class MasterConfig(BaseModel):
    """The main configuration model that aggregates all other configs."""

    global_config: GlobalConfig = Field(..., alias="global")
    backend: BackendConfig = Field(default_factory=BackendConfig)
    frontend: FrontendConfig = Field(default_factory=FrontendConfig)

    model_config = {"validate_by_name": True}


app = FastAPI(
    title="Project Generation Service",
    description="Generates project structures from templates based on user configuration.",
    version="1.0.0",
)


# Add request logging middleware
@app.middleware("http")
async def log_requests(
    request: Request, call_next: Callable[[Request], Any]
) -> Response:
    """
    Log all incoming HTTP requests to help debug Uvicorn warnings.
    """
    # Log basic request info
    logger.info(f"🌐 {request.method} {request.url.path}")
    logger.info(f"🔗 Origin: {request.headers.get('origin', 'No Origin')}")
    logger.info(f"🖥️  User-Agent: {request.headers.get('user-agent', 'No User-Agent')}")
    logger.info(
        f"📄 Content-Type: {request.headers.get('content-type', 'No Content-Type')}"
    )

    # Log all headers for debugging
    headers_dict = dict(request.headers)
    logger.info(f"📋 All Headers: {headers_dict}")

    try:
        # Process the request
        response = await call_next(request)
        logger.info(f"✅ Response status: {response.status_code}")
        return response
    except Exception as e:
        logger.error(f"❌ Request processing failed: {str(e)}")
        raise


# Constants
RAILWAY_ORIGIN = "https://railway.com"
GITHUB_PAGES_ORIGIN = "https://vakac995.github.io"

# CORS Configuration
allowed_origins = [
    RAILWAY_ORIGIN,  # Railway main domain
    GITHUB_PAGES_ORIGIN,  # GitHub Pages main domain
    "https://vakac995.github.io/easySH",  # GitHub Pages project path
    "https://vakac995.github.io/easySH/",  # GitHub Pages project path with trailing slash
]

# Add localhost origins for development
environment = os.getenv("ENVIRONMENT", "development").lower()
if environment == "development":
    allowed_origins.extend(
        [
            "http://localhost:5173",
            "http://127.0.0.1:5173",
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "https://localhost:8000",
            "https://127.0.0.1:8000",
        ]
    )

# Add VS Code port forwarding support
port_forwarding_url = os.getenv("VSCODE_PORT_FORWARDING_URL")
if port_forwarding_url:
    allowed_origins.append(port_forwarding_url)
    allowed_origins.append(f"{port_forwarding_url}/")  # with trailing slash


# NOTE: Standard CORS middleware is disabled to avoid conflicts with Railway's infrastructure
# Instead, we use explicit Railway-compatible headers on individual endpoints
# Environment-aware CORS Headers Function
def add_cors_headers(
    response: Response, request_origin: Optional[str] = None
) -> Response:
    """
    Apply environment-appropriate CORS headers to a response.

    For development: Allows localhost origins for local testing
    For production: Uses GitHub Pages origins

    Args:
        response: The FastAPI Response object to modify
        request_origin: The origin from the request headers

    Returns:
        The response object with appropriate CORS headers added
    """
    # Production: Check if origin is from allowed GitHub Pages origins
    github_origins = [
        *allowed_origins,
        "https://vakac995.github.io",
        "https://vakac995.github.io/easySH",
        "https://vakac995.github.io/easySH/",
    ]
    if request_origin and request_origin in github_origins:
        response.headers["Access-Control-Allow-Origin"] = request_origin
    else:
        response.headers["Access-Control-Allow-Origin"] = GITHUB_PAGES_ORIGIN

    if request_origin:
        logger.info(f"🔍 CORS check - Request origin: {request_origin}")
        logger.info(
            f"✅ CORS response origin: {response.headers.get('Access-Control-Allow-Origin')}"
        )

    response.headers["Access-Control-Allow-Methods"] = (
        "GET, POST, PUT, DELETE, OPTIONS, HEAD"
    )
    response.headers["Access-Control-Allow-Headers"] = (
        "Accept, Accept-Language, Content-Language, Content-Type, "
        "Authorization, X-Requested-With, Origin, Access-Control-Request-Method, "
        "Access-Control-Request-Headers, Cache-Control, Pragma"
    )
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["Access-Control-Expose-Headers"] = (
        "Content-Disposition, Content-Length"
    )
    response.headers["Access-Control-Max-Age"] = "86400"
    return response


template_dir = Path(__file__).parent / "templates"
jinja_env = Environment(loader=FileSystemLoader(template_dir), autoescape=True)


def _process_template_directory(
    zip_file: zipfile.ZipFile,
    config: MasterConfig,
    dir_name: str,
    template_dir_path: Path,
    jinja_env: Environment,
):
    """
    Process Jinja2 templates from a directory and add rendered files to ZIP archive.

    Args:
        zip_file: ZIP archive to add rendered files to
        config: Master configuration object for template rendering
        dir_name: Directory name being processed (e.g., 'backend', 'frontend')
        template_dir_path: Root path of the templates directory
        jinja_env: Jinja2 environment for template processing

    Raises:
        HTTPException: If template rendering fails
    """
    source_dir = template_dir_path / dir_name
    for root, _, files in os.walk(source_dir):
        template_root_path = Path(root)
        for filename in files:
            if not filename.endswith(".jinja2"):
                continue

            template_path = template_root_path / filename
            try:
                template_name_for_loader = str(
                    template_path.relative_to(template_dir)
                ).replace("\\", "/")
                template = jinja_env.get_template(template_name_for_loader)

                rendered_content = template.render(
                    config=config.model_dump(by_alias=True)
                )

                relative_path_in_project = template_root_path.relative_to(source_dir)
                final_filename = filename.removesuffix(".jinja2")
                project_part_name = (
                    config.backend.projectName
                    if dir_name == "backend"
                    else config.frontend.projectName
                )

                zip_path = (
                    Path(config.global_config.projectName)
                    / project_part_name
                    / relative_path_in_project
                    / final_filename
                )
                zip_file.writestr(str(zip_path), rendered_content)
            except Exception as e:
                logger.error(f"Error processing template {template_path}: {e}")
                raise HTTPException(
                    status_code=500,
                    detail=f"Failed to render template: {filename}",
                )


@app.post("/api/generate", tags=["Generation"])
async def generate_project(config: MasterConfig):
    """
    Generate a project archive based on provided configuration.

    Creates a zip archive containing the generated project structure with rendered
    templates based on the user's configuration choices.

    Args:
        config: Master configuration object containing global, backend, and frontend settings

    Returns:
        StreamingResponse: ZIP archive download with the generated project

    Raises:
        HTTPException: If neither backend nor frontend is included in the configuration
        HTTPException: If template rendering fails
    """
    try:
        logger.info(
            f"✅ Received project generation request for: {config.global_config.projectName}"
        )
        logger.info(
            f"Backend included: {config.backend.include}, Frontend included: {config.frontend.include}"
        )

        if not config.backend.include and not config.frontend.include:
            logger.error(
                "❌ Project generation failed: No backend or frontend selected"
            )
            raise HTTPException(
                status_code=400,
                detail="At least one part of the project (backend or frontend) must be included.",
            )

    except Exception as e:
        logger.error("❌ Project generation failed with error")
        logger.error(f"Error type: {type(e).__name__}")
        logger.error(f"Error message: {str(e)}")
        logger.error(f"Request data: {config.model_dump() if config else 'None'}")
        raise

    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zip_file:
        dirs_to_process: List[str] = []
        if config.backend.include:
            dirs_to_process.append("backend")
        if config.frontend.include:
            dirs_to_process.append("frontend")

        for dir_name in dirs_to_process:
            _process_template_directory(
                zip_file, config, dir_name, template_dir, jinja_env
            )

        # Add the setup script to the root of the project
        try:
            setup_template = jinja_env.get_template("setup_environment.sh.jinja2")
            rendered_setup_script = setup_template.render(
                config=config.model_dump(by_alias=True)
            )
            setup_script_path = (
                Path(config.global_config.projectName) / "setup_environment.sh"
            )
            zip_file.writestr(str(setup_script_path), rendered_setup_script)
        except Exception as e:
            logger.error(f"Error processing setup_environment.sh template: {e}")
            raise HTTPException(
                status_code=500,
                detail="Failed to render setup_environment.sh",
            )

    logger.info("✅ Project generation completed successfully")

    # Rewind buffer to the beginning
    zip_buffer.seek(0)
    zip_filename = f"{config.global_config.projectName}.zip"

    # Create headers with CORS support
    headers = {"Content-Disposition": f'attachment; filename="{zip_filename}"'}
    # Add CORS headers for development vs production
    if environment == "development":
        headers["Access-Control-Allow-Origin"] = "*"
    else:
        headers["Access-Control-Allow-Origin"] = GITHUB_PAGES_ORIGIN

    headers.update(
        {
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS, HEAD",
            "Access-Control-Allow-Headers": (
                "Accept, Accept-Language, Content-Language, Content-Type, "
                "Authorization, X-Requested-With, Origin, Access-Control-Request-Method, "
                "Access-Control-Request-Headers, Cache-Control, Pragma"
            ),
            "Access-Control-Allow-Credentials": "true",
            "Access-Control-Expose-Headers": "Content-Disposition, Content-Length",
            "Access-Control-Max-Age": "86400",
        }
    )

    return StreamingResponse(zip_buffer, media_type="application/zip", headers=headers)


@app.options("/api/generate", tags=["Generation"])
async def generate_project_options() -> Response:
    """Handle CORS preflight requests for the generate endpoint."""
    response = Response(status_code=200)
    return add_cors_headers(response)


@app.get("/", tags=["Health Check"])
def read_root() -> Response:
    """
    Root health check endpoint.

    Returns:
        JSON response indicating the API is running
    """
    response = JSONResponse(
        content={"status": "ok", "message": "Project Generation API is running."}
    )
    return add_cors_headers(response)


@app.get("/api/cors-test", tags=["Health Check"])
def cors_test() -> Response:
    """
    CORS test endpoint with environment-appropriate headers.

    Returns:
        JSON response with CORS headers for cross-origin testing
    """
    logger.info("CORS test endpoint called successfully")
    response = JSONResponse(
        content={
            "status": "success",
            "message": "CORS is working correctly",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )
    return add_cors_headers(response)


@app.options("/api/cors-test", tags=["Health Check"])
def cors_test_options() -> Response:
    """Handle CORS preflight requests for the CORS test endpoint."""
    response = Response(status_code=200)
    return add_cors_headers(response)


@app.get("/health", tags=["Health Check"])
def health_check() -> Response:
    """
    Detailed health check endpoint with environment-appropriate CORS headers.

    Returns:
        JSON response with service status and CORS headers
    """
    logger.info("Health check endpoint called")
    response = JSONResponse(
        content={
            "status": "healthy",
            "service": "easySH-backend",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )
    return add_cors_headers(response)


# Global exception handler for validation errors
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """
    Handle request validation errors with detailed logging.
    """
    logger.error("❌ Invalid HTTP request received")
    logger.error(f"Request URL: {request.url}")
    logger.error(f"Request method: {request.method}")
    logger.error(f"Validation errors: {exc.errors()}")
    logger.error("Request body validation failed")

    # Log the full traceback for debugging
    logger.error(f"Full error details: {str(exc)}")

    return JSONResponse(
        status_code=422,
        content={
            "detail": "Invalid request format",
            "errors": exc.errors(),
            "message": "The request data does not match the expected format",
        },
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """
    Handle general exceptions with logging.
    """
    logger.error("❌ Unexpected error occurred")
    logger.error(f"Request URL: {request.url}")
    logger.error(f"Request method: {request.method}")
    logger.error(f"Error type: {type(exc).__name__}")
    logger.error(f"Error message: {str(exc)}")
    logger.error(f"Traceback: {traceback.format_exc()}")

    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "message": "An unexpected error occurred while processing your request",
        },
    )


@app.options("/{full_path:path}")
async def options_handler(request: Request) -> Response:
    """
    Handle CORS preflight requests for any path.
    This catches all OPTIONS requests that might be causing Uvicorn warnings.
    """
    origin = request.headers.get("origin")
    logger.info(f"🔍 CORS preflight request to: {request.url.path}")
    logger.info(f"🔗 Origin: {origin or 'No Origin'}")
    logger.info(
        f"🎯 Access-Control-Request-Method: {request.headers.get('access-control-request-method', 'None')}"
    )
    logger.info(
        f"📋 Access-Control-Request-Headers: {request.headers.get('access-control-request-headers', 'None')}"
    )

    response = Response(status_code=200)
    return add_cors_headers(response, origin)
