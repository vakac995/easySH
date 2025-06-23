import os
import io
import zipfile
import logging
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse, Response
from pydantic import BaseModel, Field
from jinja2 import Environment, FileSystemLoader

# Configure logging
logging.basicConfig(level=logging.INFO)
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

# CORS Configuration
allowed_origins = [
    "https://vakac995.github.io",  # GitHub Pages main domain
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
        ]
    )


# NOTE: Standard CORS middleware is disabled to avoid conflicts with Railway's infrastructure
# Instead, we use explicit Railway-compatible headers on individual endpoints
# Railway CORS Headers Function
def add_railway_cors_headers(response: Response) -> Response:
    """
    Apply Railway-compatible CORS headers to a response.

    This function adds explicit CORS headers that align with Railway's infrastructure
    to avoid conflicts with their built-in CORS handling.

    Args:
        response: The FastAPI Response object to modify

    Returns:
        The response object with Railway-compatible CORS headers added
    """
    response.headers["Access-Control-Allow-Origin"] = "https://railway.com"
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
    logger.info(
        f"Received project generation request for: {config.global_config.projectName}"
    )
    logger.info(
        f"Backend included: {config.backend.include}, Frontend included: {config.frontend.include}"
    )

    if not config.backend.include and not config.frontend.include:
        raise HTTPException(
            status_code=400,
            detail="At least one part of the project (backend or frontend) must be included.",
        )

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

    # Rewind buffer to the beginning
    zip_buffer.seek(0)
    zip_filename = f"{config.global_config.projectName}.zip"
    headers = {"Content-Disposition": f'attachment; filename="{zip_filename}"'}

    return StreamingResponse(zip_buffer, media_type="application/zip", headers=headers)


@app.options("/api/generate", tags=["Generation"])
async def generate_project_options() -> Response:
    """Handle CORS preflight requests for the generate endpoint."""
    response = Response(status_code=200)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = (
        "Content-Type, Authorization, X-Requested-With"
    )
    response.headers["Access-Control-Max-Age"] = "86400"
    return response


@app.get("/", tags=["Health Check"])
def read_root() -> JSONResponse:
    """
    Root health check endpoint.

    Returns:
        JSON response indicating the API is running
    """
    return JSONResponse(
        content={"status": "ok", "message": "Project Generation API is running."}
    )


@app.get("/api/cors-test", tags=["Health Check"])
def cors_test() -> Response:
    """    CORS test endpoint with Railway-compatible headers.

    Returns:
        JSON response with Railway CORS headers for cross-origin testing
    """
    logger.info("CORS test endpoint called successfully")
    response = JSONResponse(
        content={
            "status": "success",
            "message": "CORS is working correctly",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )
    return add_railway_cors_headers(response)


@app.options("/api/cors-test", tags=["Health Check"])
def cors_test_options() -> Response:
    """Handle CORS preflight requests for the CORS test endpoint."""
    response = Response(status_code=200)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = (
        "Content-Type, Authorization, X-Requested-With"
    )
    response.headers["Access-Control-Max-Age"] = "86400"
    return response


@app.get("/health", tags=["Health Check"])
def health_check() -> Response:
    """
    Detailed health check endpoint with Railway CORS headers.

    Returns:
        JSON response with service status and Railway-compatible CORS headers
    """
    logger.info("Health check endpoint called")
    response = JSONResponse(
        content={
            "status": "healthy",
            "service": "easySH-backend",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )
    return add_railway_cors_headers(response)
