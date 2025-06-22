# ==============================================================================
#
#               PYTHON BACKEND - PROJECT GENERATION SERVICE
#
# This file contains a complete FastAPI application that serves as the backend
# for the Interactive Project Generator.
#
# Project Structure Expectation:
# -----------------------------
# ./
# ├── main.py              (This file)
# ├── requirements.txt     (Python dependencies)
# └── templates/           (Directory containing all template files)
#     ├── backend/
#     │   ├── .env.jinja2
#     │   ├── docker-compose.yml.jinja2
#     │   └── ... (other backend template files)
#     └── frontend/
#         ├── package.json.jinja2
#         └── ... (other frontend template files)
#
# How to run:
# ------------
# 1. Install dependencies: pip install -r requirements.txt
# 2. Run the server: uvicorn main:app --reload
#
# The API will be available at http://127.0.0.1:8000
# The generation endpoint is POST /api/generate
#
# ==============================================================================

# ------------------------------------------------------------------------------
# main.py - The FastAPI Application
# ------------------------------------------------------------------------------
import os
import io
import zipfile
from pathlib import Path
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from jinja2 import Environment, FileSystemLoader

# --- Pydantic Models ---
# These models define the exact structure of the JSON object expected from the
# frontend. This provides strong validation and type safety.


class GlobalConfig(BaseModel):
    projectName: str = Field(
        ..., min_length=1, description="Overall project name for the root folder."
    )


class BackendModule(BaseModel):
    id: str
    name: str
    permissions: str


class BackendFeature(BaseModel):
    id: str


class BackendModuleSystem(BaseModel):
    include: bool = False
    modules: List[BackendModule] = []
    features: List[BackendFeature] = []


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


class FrontendConfig(BaseModel):
    include: bool = False
    projectName: str = "frontend"
    includeExamplePages: bool = False
    includeHusky: bool = False
    moduleSystem: FrontendModuleSystem = Field(default_factory=FrontendModuleSystem)


class MasterConfig(BaseModel):
    global_config: GlobalConfig = Field(..., alias="global")
    backend: BackendConfig = Field(default_factory=BackendConfig)
    frontend: FrontendConfig = Field(default_factory=FrontendConfig)

    model_config = {"validate_by_name": True}


# --- FastAPI App Initialization ---
app = FastAPI(
    title="Project Generation Service",
    description="Generates project structures from templates based on user configuration.",
    version="1.0.0",
)

# --- Constants ---
CORS_METHODS = "GET, POST, PUT, DELETE, OPTIONS"

# --- Simple CORS Solution ---
# Since Railway overrides CORS headers, let's try a basic approach

# Add the production frontend URL to the list of allowed origins
# This will allow the frontend hosted on GitHub Pages to communicate with the backend.
origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "https://vakac995.github.io",  # Production frontend
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Jinja2 Template Engine Setup ---
# This assumes a 'templates' directory exists in the same location as main.py
template_dir = Path(__file__).parent / "templates"
jinja_env = Environment(loader=FileSystemLoader(template_dir), autoescape=True)


def _process_template_directory(
    zip_file: zipfile.ZipFile,
    config: MasterConfig,
    dir_name: str,
    template_dir: Path,
    jinja_env: Environment,
):
    """Processes a single directory of templates (e.g., 'backend' or 'frontend')."""
    source_dir = template_dir / dir_name
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
                print(f"Error processing template {template_path}: {e}")
                raise HTTPException(
                    status_code=500,
                    detail=f"Failed to render template: {filename}",
                )


# --- API Endpoint Definition ---
@app.post("/api/generate", tags=["Generation"])
async def generate_project(config: MasterConfig):
    """
    Accepts a JSON configuration and returns a zipped project archive.
    """
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
            print(f"Error processing setup_environment.sh template: {e}")
            raise HTTPException(
                status_code=500,
                detail="Failed to render setup_environment.sh",
            )

    # Rewind buffer to the beginning
    zip_buffer.seek(0)  # Set headers for file download and CORS
    zip_filename = f"{config.global_config.projectName}.zip"
    headers = {
        "Content-Disposition": f'attachment; filename="{zip_filename}"',
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": CORS_METHODS,
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Expose-Headers": "*",
    }

    return StreamingResponse(zip_buffer, media_type="application/zip", headers=headers)


# --- Health Check Endpoint ---
@app.get("/", tags=["Health Check"])
def read_root():
    """A simple health check endpoint."""
    return JSONResponse(
        content={"status": "ok", "message": "Project Generation API is running."},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": CORS_METHODS,
            "Access-Control-Allow-Headers": "*",
        },
    )


# ==============================================================================
# requirements.txt - Python Dependencies
#
# Create a file named 'requirements.txt' with the following content.
# Then run 'pip install -r requirements.txt'.
# ==============================================================================
# fastapi
# uvicorn[standard]
# pydantic
# Jinja2
# python-multipart
# ==============================================================================


# ==============================================================================
# EXAMPLE TEMPLATE FILES
#
# These files must be created inside the 'templates/' directory.
# The structure inside 'templates/' should mirror the desired output structure.
# ==============================================================================

# ------------------------------------------------------------------------------
# File: templates/backend/docker-compose.yml.jinja2
# ------------------------------------------------------------------------------
# version: '3.8'
#
# services:
#   backend:
#     build: .
#     container_name: {{ config.backend.projectName }}
#     command: uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
#     volumes:
#       - ./src:/app/src
#     ports:
#       - "8000:8000"
#     environment:
#       - DATABASE_URL=postgresql://{{ config.backend.dbUser }}:{{ config.backend.dbPassword }}@{{ config.backend.dbHost }}:{{ config.backend.dbPort }}/{{ config.backend.dbName }}
#       - LOG_LEVEL={{ config.backend.logLevel }}
#       - DEBUG={{ config.backend.debug }}
#     depends_on:
#       - postgres
#
#   postgres:
#     image: postgres:13
#     container_name: {{ config.backend.dbHost }}
#     environment:
#       - POSTGRES_USER={{ config.backend.dbUser }}
#       - POSTGRES_PASSWORD={{ config.backend.dbPassword }}
#       - POSTGRES_DB={{ config.backend.dbName }}
#     ports:
#       - "5432:5432"
#     volumes:
#       - postgres_data:/var/lib/postgresql/data
#
#   pgadmin:
#     image: dpage/pgadmin4
#     container_name: pgadmin_service
#     environment:
#       - PGADMIN_DEFAULT_EMAIL={{ config.backend.pgAdminEmail }}
#       - PGADMIN_DEFAULT_PASSWORD={{ config.backend.pgAdminPassword }}
#     ports:
#       - "5050:80"
#     depends_on:
#       - postgres
#
# volumes:
#   postgres_data:
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# File: templates/frontend/src/App.tsx.jinja2
# ------------------------------------------------------------------------------
# import React from 'react';
#
# // This demonstrates conditional logic based on the config.
# {% if config.frontend.moduleSystem.include %}
# import { ConfigProvider } from './providers/ConfigProvider';
# import { useConfig } from './hooks/useConfig';
# {% endif %}
#
# function MainContent() {
#   {% if config.frontend.moduleSystem.include %}
#   const { features, hasPermission } = useConfig();
#   {% endif %}
#
#   return (
#     <div className="App">
#       <h1>Welcome to {{ config.frontend.projectName }}!</h1>
#
#       {% if config.frontend.includeExamplePages %}
#       <p>This is an example page component.</p>
#       {% endif %}
#
#       {% if config.frontend.moduleSystem.include %}
#       <h2>Feature Flags:</h2>
#       <ul>
#         {% for feature in config.frontend.moduleSystem.features %}
#         <li>{{ feature.id }}: { features.{{ feature.id }} ? 'Enabled' : 'Disabled' }</li>
#         {% endfor %}
#       </ul>
#
#       <h2>Modules & Permissions:</h2>
#       <ul>
#         {% for module in config.frontend.moduleSystem.modules %}
#         <li>
#           <strong>{{ module.name }}</strong>
#           (Can access: {hasPermission('{{ module.permissions.split(',')[0] if module.permissions else '' }}') ? 'Yes' : 'No'})
#         </li>
#         {% endfor %}
#       </ul>
#       {% endif %}
#     </div>
#   );
# }
#
# function App() {
#   {% if config.frontend.moduleSystem.include %}
#   return (
#     <ConfigProvider>
#       <MainContent />
#     </ConfigProvider>
#   );
#   {% else %}
#   return <MainContent />;
#   {% endif %}
# }
#
# export default App;
# ------------------------------------------------------------------------------
