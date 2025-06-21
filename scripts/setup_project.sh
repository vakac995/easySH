#!/bin/bash

# ============================================================================
# 🚀 SCRIPT BOOSTER FRAMEWORK - READY TO USE
# ============================================================================
# Save this as: setup_project.sh
# Make executable: chmod +x setup_project.sh
# Run with: ./setup_project.sh [project_name]
#
# PROJECT CUSTOMIZATION CHECKLIST:
# 1. Edit the "PROJECT CONFIGURATION" section (lines 75-85)
# 2. Edit the "PREREQUISITES" section (lines 87-95)
# 3. Edit steps in the "STEP DEFINITIONS" section (lines 100-350)
# 4. Update TOTAL_STEPS count (line 105)
# 5. Update run_steps() function (lines 515-535)
# ============================================================================

set -euo pipefail # Exit on error, undefined vars, pipe failures

# ============================================================================
# 🎨 FRAMEWORK CORE - DO NOT MODIFY
# ============================================================================

# Colors and formatting
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[1;33m'
declare -r BLUE='\033[0;34m'
declare -r PURPLE='\033[0;35m'
declare -r CYAN='\033[0;36m'
declare -r WHITE='\033[1;37m'
declare -r NC='\033[0m'

# Global state
declare -g SCRIPT_START_TIME
declare -g CURRENT_STEP=0
declare -g TOTAL_STEPS=0
declare -g PROJECT_ROOT=""
declare -g LOG_FILE=""
declare -ga CLEANUP_TASKS=()
declare -ga TERMINAL_PIDS=()

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
log_step() { echo -e "${PURPLE}[STEP $1/$TOTAL_STEPS]${NC} $2" | tee -a \
  "$LOG_FILE"; }

# Progress tracking
# start_step - Increments the step counter and logs the current step description.
#   $1: Description of the current step.
start_step() {
  ((CURRENT_STEP++))
  log_step "$CURRENT_STEP" "$1"
}

# User interaction
# ask_user - Prompts the user with a question and reads input.
#   $1: Question to display.
#   $2: Default answer (default: 'y').
# Returns the user's input or the default if none provided.
ask_user() {
  local question="$1"
  local default="${2:-y}"
  local response

  echo -e "${CYAN}❓ $question${NC}"
  read -r -p "Enter choice (${default}): " response
  response=${response:-$default}
  echo "$response"
}

# wait_for_user - Pauses execution until the user presses Enter.
wait_for_user() {
  echo -e "${YELLOW}⏸️  Press Enter to continue or Ctrl+C to exit...${NC}"
  read -r
}

# Command execution with error handling
# run_command - Executes a shell command and logs its progress.
#   $1: Command to execute.
#   $2: Error message if command fails.
# Returns non-zero on failure.
run_command() {
  local cmd="$1"
  local error_msg="${2:-Command failed}"

  log_info "Executing: $cmd"
  if ! eval "$cmd" >>"$LOG_FILE" 2>&1; then
    log_error "$error_msg"
    log_error "Check $LOG_FILE for details"
    return 1
  fi
  return 0
}

# Non-blocking terminal management
# open_terminal - Opens a new terminal window and runs a command.
#   $1: Title of the terminal window.
#   $2: Command to execute in the terminal.
open_terminal() {
  local title="$1"
  local command="$2"
  local current_dir="$PROJECT_ROOT"

  if command -v cmd >/dev/null 2>&1; then
    # Windows Git Bash
    cmd //c start "Git Bash - $title" "C:\Program Files\Git\bin\bash.exe" -c \
      "cd '$current_dir' && $command; echo 'Press any key to close...'; read -n 1" &
    TERMINAL_PIDS+=($!)
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    osascript -e "tell application \"Terminal\" to do script \"cd \
$PROJECT_ROOT && $command\"" &
    TERMINAL_PIDS+=($!)
  elif command -v gnome-terminal >/dev/null 2>&1; then
    # Linux with GNOME
    gnome-terminal --title="$title" --working-directory="$current_dir" -- \
      bash -c "$command; read -p 'Press Enter to close...'" &
    TERMINAL_PIDS+=($!)
  else
    log_warning "Could not open terminal automatically"
    echo -e "${CYAN}Manual command:${NC} cd $current_dir && $command"
  fi
}

# File operations
# create_file - Creates a file with specified content.
#   $1: File path to create.
#   $2: Content to write into the file.
#   $3: Description of the file for logging.
create_file() {
  local file_path="$1"
  local content="$2"
  local description="${3:-file}"

  log_info "Creating $description: $file_path"
  mkdir -p "$(dirname "$file_path")"
  echo "$content" >"$file_path"
  log_success "$description created successfully"
}

# create_directory - Creates a directory and any necessary parent directories.
#   $1: Directory path to create.
#   $2: Description of the directory for logging.
create_directory() {
  local dir_path="$1"
  local description="${2:-directory}"

  log_info "Creating $description: $dir_path"
  mkdir -p "$dir_path"
  log_success "$description created successfully"
}

# Prerequisites checking
# require_command - Checks if a command is available.
#   $1: Command name to check.
#   $2: Custom message if command not found.
# Returns non-zero if the command is not found.
require_command() {
  local cmd="$1"
  local install_msg="${2:-Please install $cmd}"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "$cmd is not installed or not in PATH"
    log_error "$install_msg"
    return 1
  fi
  log_success "$cmd is available"
  return 0
}

# Service management
# start_service - Starts a named service with an optional health check.
#   $1: Service name.
#   $2: Command to start the service.
#   $3: Optional health check command (0 when ready).
#   $4: Max wait time in seconds for health check.
start_service() {
  local service_name="$1"
  local start_command="$2"
  local health_check="${3:-}"
  local max_wait="${4:-30}"

  log_info "Starting $service_name..."

  if ! run_command "$start_command" "Failed to start $service_name"; then
    return 1
  fi

  if [[ -n "$health_check" ]]; then
    log_info "Waiting for $service_name to be ready..."
    local attempt=1
    while [ $attempt -le $max_wait ]; do
      if eval "$health_check" >/dev/null 2>&1; then
        log_success "$service_name is ready!"
        return 0
      fi
      log_info "Waiting for $service_name... (attempt $attempt/$max_wait)"
      sleep 2
      ((attempt++))
    done
    log_warning "$service_name health check timed out"
    return 1
  fi

  log_success "$service_name started successfully"
  return 0
}

# Cleanup management
# add_cleanup_task - Registers a cleanup command to run on exit.
#   $1: Command to execute during cleanup.
add_cleanup_task() {
  CLEANUP_TASKS+=("$1")
}

# run_cleanup - Executes all registered cleanup tasks and closes any opened terminals.
run_cleanup() {
  if [ ${#CLEANUP_TASKS[@]} -gt 0 ]; then
    log_info "Running cleanup tasks..."
    for task in "${CLEANUP_TASKS[@]}"; do
      log_info "Cleanup: $task"
      eval "$task" || log_warning "Cleanup task failed: $task"
    done
  fi

  # Kill opened terminals if needed
  if [ ${#TERMINAL_PIDS[@]} -gt 0 ]; then
    log_info "Cleanup: Closing opened terminals..."
    for pid in "${TERMINAL_PIDS[@]}"; do
      kill "$pid" 2>/dev/null || true
    done
  fi
}

# Error handling
# handle_error - Error handler for the script.
# Logs the error, runs cleanup tasks, and exits with the error code.
handle_error() {
  local exit_code=$?
  log_error "Script failed with exit code $exit_code"
  run_cleanup
  exit $exit_code
}

# Initialize framework
# init_framework - Initializes the framework (sets project root, log file, traps, etc).
init_framework() {
  SCRIPT_START_TIME=$(date +%s)
  PROJECT_ROOT="$(pwd)/${PROJECT_NAME}"
  LOG_FILE="${PROJECT_ROOT}/setup.log"

  # Create project directory if it doesn't exist
  mkdir -p "$PROJECT_ROOT"

  # Initialize log file
  echo "=== Script started at $(date) ===" >"$LOG_FILE"

  # Set up error handling
  trap handle_error ERR
  trap run_cleanup EXIT

  log_success "Framework initialized"
}

# ============================================================================
# 📝 PROJECT CONFIGURATION - Project settings
# ============================================================================

# Project details
PROJECT_NAME="${1:-awesome_postgres_app}"
PROJECT_DESCRIPTION="PostgreSQL Application with SQLAlchemy"
PROJECT_VERSION="1.0.0"

# Prerequisites (format: "command:install_message")
REQUIRED_COMMANDS=(
  "docker:Please install Docker Desktop from https://docker.com"
  "docker-compose:Please install Docker Compose"
  "git:Please install Git"
)

# ============================================================================
# 🏗️ STEP DEFINITIONS - Add project-specific steps here
# ============================================================================

# define_steps - Defines all project setup steps and sets TOTAL_STEPS count.
define_steps() {
  # Update TOTAL_STEPS to reflect defined steps
  TOTAL_STEPS=8

  # step_create_structure - Step 1: Create project folder structure.
  step_create_structure() {
    start_step "Creating project structure"

    # Create directories
    create_directory "$PROJECT_ROOT/src" "source code directory"
    create_directory "$PROJECT_ROOT/sql/init" "SQL initialization directory"
    create_directory "$PROJECT_ROOT/sql/queries" "SQL queries directory"
    create_directory "$PROJECT_ROOT/config" "configuration directory"
    create_directory "$PROJECT_ROOT/logs" "logs directory"
    create_directory "$PROJECT_ROOT/backups" "backups directory"

    log_success "Project structure created"
  }

  # step_create_configs - Step 2: Create configuration files.
  step_create_configs() {
    start_step "Creating configuration files"

    # Environment file
    local env_content="# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=postgres_app_db
DB_USER=postgres_user
DB_PASSWORD=secure_password_123
DB_ECHO=false

# PgAdmin Configuration
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=admin123

# Application Configuration
DEBUG=true
LOG_LEVEL=INFO"

    create_file "$PROJECT_ROOT/.env" "$env_content" "environment configuration"

    # GitIgnore
    local gitignore_content="# Environment files
.env
.env.local

# Python
__pycache__/
*.py[cod]
venv/
env/

# Logs
logs/*.log
*.log

# Database
backups/*.sql

# IDE
.vscode/
.idea/"

    create_file "$PROJECT_ROOT/.gitignore" "$gitignore_content" "gitignore file"

    # Requirements
    local requirements="sqlalchemy>=2.0.0
psycopg2-binary>=2.9.0
python-dotenv>=1.0.0
fastapi>=0.104.0
uvicorn>=0.24.0
gunicorn>=21.2.0
pydantic>=2.0.0"

    create_file "$PROJECT_ROOT/requirements.txt" "$requirements" "Python requirements"

    log_success "Configuration files created"
  }

  # step_create_database_manager - Step 3: Create database manager code.
  step_create_database_manager() {
    start_step "Creating database manager"

    local db_manager='"""
PostgreSQL Database Manager with SQLAlchemy
Singleton pattern with raw SQL support
"""
import os
import logging
from typing import Optional, Any, Dict, List, Union
from contextlib import contextmanager
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import SQLAlchemyError

logger = logging.getLogger(__name__)

class DatabaseManager:
    _instance = None
    _engine = None
    _session_factory = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(DatabaseManager, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not hasattr(self, "initialized"):
            self.initialized = True
            self._setup_connection()
    
    def _setup_connection(self):
        try:
            db_url = self._get_database_url()
            self._engine = create_engine(db_url, echo=os.getenv("DB_ECHO", "false").lower() == "true")
            self._session_factory = sessionmaker(bind=self._engine)
            logger.info("Database connection established")
        except Exception as e:
            logger.error(f"Database connection failed: {e}")
            raise
    
    def _get_database_url(self):
        host = os.getenv("DB_HOST", "localhost")
        port = os.getenv("DB_PORT", "5432")
        database = os.getenv("DB_NAME", "postgres_app_db")
        username = os.getenv("DB_USER", "postgres_user")
        password = os.getenv("DB_PASSWORD", "secure_password_123")
        return f"postgresql://{username}:{password}@{host}:{port}/{database}"
    
    @contextmanager
    def get_session(self):
        session = self._session_factory()
        try:
            yield session
            session.commit()
        except Exception as e:
            session.rollback()
            logger.error(f"Database session error: {e}")
            raise
        finally:
            session.close()
    
    def execute_raw_sql(self, query: str, params: Optional[Dict[str, Any]] = None, fetch_all: bool = True):
        with self.get_session() as session:
            try:
                result = session.execute(text(query), params or {})
                if query.strip().upper().startswith(("SELECT", "WITH")):
                    if fetch_all:
                        rows = result.fetchall()
                        return [dict(row._mapping) for row in rows]
                    else:
                        row = result.fetchone()
                        return dict(row._mapping) if row else None
                else:
                    return {"affected_rows": result.rowcount}
            except SQLAlchemyError as e:
                logger.error(f"SQL execution error: {e}")
                raise

def get_db_manager():
    return DatabaseManager()

def execute_sql(query: str, params: Optional[Dict[str, Any]] = None, fetch_all: bool = True):
    return get_db_manager().execute_raw_sql(query, params, fetch_all)
'

    create_file "$PROJECT_ROOT/src/database_manager.py" "$db_manager" "database manager"

    log_success "Database manager created"
  }

  # step_create_app_files - Step 4: Create main application files.
  step_create_app_files() {
    start_step "Creating application files"

    # Main application
    local main_app='"""
FastAPI Application with PostgreSQL
Production-ready with Gunicorn support
"""
import logging
import os
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
from src.database_manager import get_db_manager, execute_sql

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# FastAPI app
app = FastAPI(
    title="PostgreSQL Application",
    description="FastAPI application with PostgreSQL and SQLAlchemy",
    version="1.0.0"
)

# Pydantic models
class User(BaseModel):
    username: str
    email: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    created_at: str

class PostResponse(BaseModel):
    id: int
    title: str
    content: str
    user_id: int
    created_at: str

@app.get("/")
async def root():
    """Health check endpoint"""
    try:
        # Test database connection
        result = execute_sql("SELECT 'Hello PostgreSQL!' as message, NOW() as current_time")
        return {
            "message": "FastAPI + PostgreSQL Application",
            "status": "healthy",
            "database": result[0] if result else "connection failed"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")

@app.get("/health")
async def health_check():
    """Detailed health check"""
    try:
        # Test database
        db_result = execute_sql("SELECT 1 as test")
        
        # Check tables
        tables_result = execute_sql("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """)
        
        return {
            "status": "healthy",
            "database": "connected",
            "tables": [row["table_name"] for row in tables_result],
            "version": "1.0.0"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/users", response_model=List[UserResponse])
async def get_users():
    """Get all users"""
    try:
        result = execute_sql("SELECT * FROM users ORDER BY created_at DESC")
        return result
    except Exception as e:
        logger.error(f"Failed to get users: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve users")

@app.get("/users/{username}", response_model=UserResponse)
async def get_user(username: str):
    """Get user by username"""
    try:
        result = execute_sql(
            "SELECT * FROM users WHERE username = :username",
            {"username": username},
            fetch_all=False
        )
        if not result:
            raise HTTPException(status_code=404, detail="User not found")
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get user {username}: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve user")

@app.get("/users/{username}/posts", response_model=List[PostResponse])
async def get_user_posts(username: str):
    """Get posts for a specific user"""
    try:
        result = execute_sql("""
            SELECT p.* 
            FROM posts p
            JOIN users u ON p.user_id = u.id
            WHERE u.username = :username
            ORDER BY p.created_at DESC
        """, {"username": username})
        return result
    except Exception as e:
        logger.error(f"Failed to get posts for {username}: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve posts")

@app.post("/users", response_model=UserResponse)
async def create_user(user: User):
    """Create a new user"""
    try:
        result = execute_sql("""
            INSERT INTO users (username, email) 
            VALUES (:username, :email)
            RETURNING *
        """, {"username": user.username, "email": user.email}, fetch_all=False)
        return result
    except Exception as e:
        logger.error(f"Failed to create user: {e}")
        raise HTTPException(status_code=500, detail="Failed to create user")

def main():
    """Main function for development testing"""
    try:
        print("=== FastAPI Application Test ===")
        
        # Test database connection
        db = get_db_manager()
        result = execute_sql("SELECT 'Hello PostgreSQL!' as message, NOW() as current_time")
        
        for row in result:
            print(f"Message: {row['message']}")
            print(f"Time: {row['current_time']}")
        
        print("✅ Database connection successful!")
        print("🚀 Start the server with: uvicorn main:app --reload")
        print("🌐 Or production: gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker")
        
    except Exception as e:
        logger.error(f"Application test failed: {e}")
        exit(1) 
'

    create_file "$PROJECT_ROOT/main.py" "$main_app" "main application"

    # Init file
    create_file "$PROJECT_ROOT/src/__init__.py" "" "Python package init"

    log_success "Application files created"
  }

  # step_create_docker_config - Step 5: Create Docker configuration files.
  step_create_docker_config() {
    start_step "Creating Docker configuration"

    # Docker Compose
    local docker_compose='version: '\''3.8'\''

services:
  postgres:
    image: postgres:15-alpine
    container_name: postgres_db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME:-postgres_app_db}
      POSTGRES_USER: ${DB_USER:-postgres_user}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-secure_password_123}
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sql/init:/docker-entrypoint-initdb.d
      - ./backups:/backups
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres_user}"]
      interval: 30s
      timeout: 10s
      retries: 3

  app:
    build: .
    container_name: postgres_app
    restart: unless-stopped
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME:-postgres_app_db}
      DB_USER: ${DB_USER:-postgres_user}
      DB_PASSWORD: ${DB_PASSWORD:-secure_password_123}
    ports:
      - "8000:8000"
    volumes:
      - .:/app
      - ./logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
    command: gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind \
0.0.0.0:8000 --access-logfile - --error-logfile -

  pgadmin:
    image: dpage/pgadmin4:7
    container_name: pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@example.com}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin123}
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      - postgres

volumes:
  postgres_data:
  pgadmin_data:'

    create_file "$PROJECT_ROOT/docker-compose.yml" "$docker_compose" "Docker \
Compose configuration"

    # Dockerfile
    local dockerfile='FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf \
/var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p logs

ENV PYTHONPATH=/app
EXPOSE 8000

# Use Gunicorn for production
CMD ["gunicorn", "main:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", \
"--bind", "0.0.0.0:8000"]'

    create_file "$PROJECT_ROOT/Dockerfile" "$dockerfile" "Dockerfile"

    log_success "Docker configuration created"
  }

  # step_create_sql_files - Step 6: Create SQL initialization and query files.
  step_create_sql_files() {
    start_step "Creating SQL initialization files"

    # Table creation script
    local create_tables='-- Create sample tables
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);'

    create_file "$PROJECT_ROOT/sql/init/01_create_tables.sql" \
      "$create_tables" "table creation script"

    # Sample data script
    local sample_data='-- Insert sample data
INSERT INTO users (username, email) VALUES
    ('\''john_doe'\'', '\''john@example.com'\''),
    ('\''jane_smith'\'', '\''jane@example.com'\''),
    ('\''bob_wilson'\'', '\''bob@example.com'\'')
ON CONFLICT (username) DO NOTHING;

INSERT INTO posts (title, content, user_id) VALUES
    ('\''Welcome Post'\'', '\''This is a welcome post content'\'', 1),
    ('\''Hello World'\'', '\''Another sample post'\'', 2),
    ('\''Getting Started'\'', '\''How to get started with our app'\'', 1)
ON CONFLICT DO NOTHING;'

    create_file "$PROJECT_ROOT/sql/init/02_sample_data.sql" \
      "$sample_data" "sample data script"

    # Query examples
    local user_posts_query='-- Get user posts with details
SELECT u.username, u.email, p.title, p.content, p.created_at
FROM users u
JOIN posts p ON u.id = p.user_id
WHERE u.username = :username
ORDER BY p.created_at DESC;'

    create_file "$PROJECT_ROOT/sql/queries/user_posts.sql" "$user_posts_query" "user posts query"

    log_success "SQL files created"
  }

  # step_create_gunicorn_config - Step 7: Create Gunicorn config and startup scripts.
  step_create_gunicorn_config() {
    start_step "Creating Gunicorn production configuration"

    # Gunicorn configuration file
    local gunicorn_conf='# Gunicorn configuration file
import multiprocessing

# Server socket
bind = "0.0.0.0:8000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000
timeout = 30
keepalive = 2

# Restart workers after this many requests, to help prevent memory leaks
max_requests = 1000
max_requests_jitter = 100

# Logging
accesslog = "/app/logs/gunicorn_access.log"
errorlog = "/app/logs/gunicorn_error.log"
loglevel = "info"
access_log_format = "%(h)s %(l)s %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\" %(D)s"

# Process naming
proc_name = "postgres_app"

# Server mechanics
daemon = False
pidfile = "/tmp/gunicorn.pid"
user = None
group = None
tmp_upload_dir = None

# SSL (uncomment for HTTPS)
# keyfile = "/path/to/keyfile"
# certfile = "/path/to/certfile"'

    create_file "$PROJECT_ROOT/gunicorn.conf.py" "$gunicorn_conf" "Gunicorn configuration"

    # Development startup script
    local dev_script='#!/bin/bash
# Development server startup script

echo "🚀 Starting development server..."
echo "📍 URL: http://localhost:8000"
echo "📖 Docs: http://localhost:8000/docs"
echo "🔄 Auto-reload enabled"
echo ""

# Use uvicorn for development (with auto-reload)
uvicorn main:app --reload --host 0.0.0.0 --port 8000'

    create_file "$PROJECT_ROOT/start_dev.sh" "$dev_script" "development startup script"
    run_command "chmod +x '$PROJECT_ROOT/start_dev.sh'" "Failed to make dev script executable"

    # Production startup script
    local prod_script='#!/bin/bash
# Production server startup script

echo "🏭 Starting production server with Gunicorn..."
echo "👥 Workers: $(python -c "import multiprocessing; \
print(multiprocessing.cpu_count() * 2 + 1)")"
echo "📍 URL: http://localhost:8000"
echo "📖 API Docs: http://localhost:8000/docs"
echo ""

# Create logs directory if it doesn'\''t exist
mkdir -p logs

# Use Gunicorn for production
gunicorn main:app \
    --config gunicorn.conf.py \
    --access-logfile logs/access.log \
    --error-logfile logs/error.log'

    create_file "$PROJECT_ROOT/start_prod.sh" "$prod_script" "production startup script"
    run_command "chmod +x '$PROJECT_ROOT/start_prod.sh'" "Failed to make prod script executable"

    # Docker startup script
    local docker_script='#!/bin/bash
# Docker production startup script

echo "🐳 Starting Docker production server..."

# Wait for database to be ready
until PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\\q"; do
  echo "⏳ Waiting for PostgreSQL to be ready..."
  sleep 2
done

echo "✅ PostgreSQL is ready!"
echo "🚀 Starting Gunicorn with $(python -c "import multiprocessing; \
print(multiprocessing.cpu_count() * 2 + 1)") workers..."

# Start Gunicorn
exec gunicorn main:app \
    -w $(python -c "import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)") \
    -k uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:8000 \
    --access-logfile - \
    --error-logfile - \
    --log-level info'

    create_file "$PROJECT_ROOT/start_docker.sh" "$docker_script" "Docker startup script"
    run_command "chmod +x '$PROJECT_ROOT/start_docker.sh'" "Failed to make Docker script executable"

    log_success "Gunicorn configuration and startup scripts created"
  }

  # step_create_documentation - Step 8: Generate project documentation.
  step_create_documentation() {
    start_step "Creating documentation"
    # Use a Heredoc to correctly assign the multi-line string to the 'readme' variable.
    # The 'EOF' delimiter is quoted to prevent the shell from expanding variables
    # like $PROJECT_DESCRIPTION within the string itself.
    local readme
    readme=$(cat <<'EOF')
# $PROJECT_DESCRIPTION

A production-ready FastAPI application with PostgreSQL, SQLAlchemy, and Gunicorn.

## Quick Start

### 🐳 **Docker (Recommended)**
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app
```

### 🔧 **Local Development**
```bash
# Install dependencies
pip install -r requirements.txt

# Start development server (auto-reload)
./start_dev.sh
# or manually: uvicorn main:app --reload
```

### 🏭 **Production**
```bash
# Start production server with Gunicorn
./start_prod.sh
# or manually: gunicorn main:app -c gunicorn.conf.py
```

## 🌐 Web Interfaces

- **API Application:** http://localhost:8000
- **API Documentation:** http://localhost:8000/docs (Swagger UI)
- **Alternative Docs:** http://localhost:8000/redoc
- **PgAdmin:** http://localhost:5050 (admin@example.com / admin123)

## 📡 API Endpoints

- `GET /` - Health check and welcome message
- `GET /health` - Detailed health check with database status
- `GET /users` - Get all users
- `GET /users/{username}` - Get specific user
- `GET /users/{username}/posts` - Get user's posts
- `POST /users` - Create new user

## 🏗️ Project Structure

```
$PROJECT_NAME/
├── src/                     # Source code
│   └── database_manager.py  # Database connection manager
├── sql/                     # SQL files
│   ├── init/                # Database initialization
│   └── queries/             # Query examples
├── logs/                    # Application logs
├── main.py                  # FastAPI application
├── gunicorn.conf.py         # Gunicorn production config
├── start_dev.sh             # Development server script
├── start_prod.sh            # Production server script
├── start_docker.sh          # Docker startup script
├── docker-compose.yml       # Docker services
└── requirements.txt         # Python dependencies
```

## 🗄️ Database Access

- **Host:** localhost:5432
- **Database:** postgres_app_db
- **Username:** postgres_user
- **Password:** secure_password_123

## 🚀 Production Features

### **Gunicorn Configuration:**
- **Workers:** Auto-calculated based on CPU cores (2 × cores + 1)
- **Worker Class:** uvicorn.workers.UvicornWorker
- **Load Balancing:** Automatic across worker processes
- **Logging:** Structured access and error logs
- **Auto-restart:** Workers restart after handling requests to prevent memory leaks

### **Performance:**
- Multiple worker processes for concurrent request handling
- Connection pooling with SQLAlchemy
- Health checks and monitoring endpoints
- Graceful error handling and logging

## 💻 Development Commands

```bash
# Development with auto-reload
./start_dev.sh

# Production with Gunicorn
./start_prod.sh

# Test database connection
python main.py

# Run with custom Gunicorn settings
gunicorn main:app -w 8 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app
docker-compose logs -f postgres

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# Access database directly
docker-compose exec postgres psql -U postgres_user -d postgres_app_db
```

## 📊 Example Usage

### **cURL Examples:**
```bash
# Health check
curl http://localhost:8000/health

# Get all users
curl http://localhost:8000/users

# Get specific user
curl http://localhost:8000/users/john_doe

# Create new user
curl -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -d '{"username": "new_user", "email": "new@example.com"}'
```

### **Python Client:**
```python
import requests

# Health check
response = requests.get("http://localhost:8000/health")
print(response.json())

# Get users
users = requests.get("http://localhost:8000/users").json()
for user in users:
    print(f"User: {user['username']} ({user['email']})")
```

### **Direct Database Access:**
```python
from src.database_manager import execute_sql

# Execute raw SQL
result = execute_sql("SELECT * FROM users WHERE username = :username", {"username": "john_doe"})

# Get user posts
posts = execute_sql("""
    SELECT u.username, p.title, p.content 
    FROM users u 
    JOIN posts p ON u.id = p.user_id 
    WHERE u.username = :username
    ORDER BY p.created_at DESC
""", {"username": "john_doe"})
```

## 🔧 Environment Configuration

Edit `.env` file to customize:
```bash
# Database settings
DB_HOST=localhost
DB_PORT=5432
DB_NAME=postgres_app_db
DB_USER=postgres_user
DB_PASSWORD=secure_password_123

# PgAdmin settings
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=admin123
```

## 📈 Monitoring & Logs

- **Application Logs:** `logs/` directory
- **Gunicorn Access Logs:** `logs/gunicorn_access.log`
- **Gunicorn Error Logs:** `logs/gunicorn_error.log`
- **Docker Logs:** `docker-compose logs -f app`

## 🔄 Load Balancing

Gunicorn automatically provides load balancing across worker processes:
- Requests are distributed among workers
- Each worker handles requests independently
- Failed workers are automatically restarted
- Graceful worker recycling prevents memory leaks

Generated by Script Booster Framework 🚀
EOF

    # The content of the readme variable now needs to have its own variables substituted.
    # We use `eval` on a "Here String" for a safe and clean substitution.
    local final_readme
    final_readme=$(eval "echo \"$(cat)\"" <<<"$readme")

    create_file "$PROJECT_ROOT/README.md" "$final_readme" "documentation"

    log_success "Documentation created"
  }
}

# ============================================================================
# 🔧 FRAMEWORK EXECUTION - DO NOT MODIFY
# ============================================================================

# display_banner - Shows the startup banner with project details.
display_banner() {
  echo -e "${WHITE}"
  echo "╔═════════════════════════════════════════════════════════════════════\
════════════════╗"
  echo "║                          🚀 SCRIPT BOOSTER FRAMEWORK              ║"
  echo "╠═════════════════════════════════════════════════════════════════════\
════════════════╣"
  echo "║  Project: $PROJECT_DESCRIPTION"
  echo "║  Version: $PROJECT_VERSION"
  echo "║  Target:  $PROJECT_NAME"
  echo "╚═════════════════════════════════════════════════════════════════════\
════════════════╝"
  echo -e "${NC}"
}

# verify_prerequisites - Checks that required commands are installed.
verify_prerequisites() {
  log_info "Checking prerequisites..."

  local all_good=true
  for req in "${REQUIRED_COMMANDS[@]}"; do
    local cmd="${req%%:*}"
    local msg="${req#*:}"
    if ! require_command "$cmd" "$msg"; then
      all_good=false
    fi
  done

  if [[ "$all_good" != "true" ]]; then
    log_error "Prerequisites check failed"
    exit 1
  fi

  log_success "All prerequisites satisfied"
}

# run_steps - Executes each defined setup step in sequence.
run_steps() {
  log_info "Starting step execution..."

  # Add or remove step invocations as needed
  step_create_structure
  step_create_configs
  step_create_database_manager
  step_create_app_files
  step_create_docker_config
  step_create_sql_files
  step_create_gunicorn_config
  step_create_documentation

  # Optional: Start services
  local start_services
  start_services=$(ask_user "🚀 Start Docker services and open monitoring terminals?" "y")
  if [[ "$start_services" =~ ^[Yy] ]]; then
    start_step "Starting Docker services"

    cd "$PROJECT_ROOT"
    start_service "Docker Compose" \
      "docker-compose up -d --build" \
      "docker-compose ps | grep -q Up" \
      60

    # Add cleanup task
    add_cleanup_task "cd '$PROJECT_ROOT' && docker-compose down"

    # Open monitoring terminals
    log_info "Opening monitoring terminals..."
    open_terminal "Docker Logs" "docker-compose logs -f"
    open_terminal "PostgreSQL Console" "sleep 5 && docker-compose exec \
postgres psql -U postgres_user -d postgres_app_db"
    open_terminal "App Monitor" "docker-compose logs -f app"

    log_success "Services started and monitoring terminals opened"
  fi
}

# display_summary - Displays project setup summary and next steps.
display_summary() {
  local duration=$(($(date +%s) - SCRIPT_START_TIME))

  echo ""
  echo -e "${GREEN}╔══════════════════════════════════════════════════════════\
════════════════╗${NC}"
  echo -e "${GREEN}║                            🎉 SETUP COMPLETE!         \
                                ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════════════\
════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}📁 Project Location:${NC} $PROJECT_ROOT"
  echo -e "${CYAN}⏱️  Total Time:${NC} ${duration}s"
  echo -e "${CYAN}📋 Log File:${NC} $LOG_FILE"
  echo ""
  echo -e "${YELLOW}🌐 Web Interfaces:${NC}"
  echo "   - FastAPI App: http://localhost:8000"
  echo "   - API Docs: http://localhost:8000/docs (Swagger UI)"
  echo "   - PgAdmin: http://localhost:5050 (admin@example.com / admin123)"
  echo ""
  echo -e "${YELLOW}🗄️  Database Connection:${NC}"
  echo "   - Host: localhost:5432"
  echo "   - Database: postgres_app_db"
  echo "   - Username: postgres_user"
  echo "   - Password: secure_password_123"
  echo ""
  echo -e "${YELLOW}🚀 Next Steps:${NC}"
  echo "   1. cd $PROJECT_NAME"
  echo "   2. ./start_dev.sh  # Start development server with auto-reload"
  echo "   3. Visit http://localhost:8000/docs for API documentation"
  echo "   4. ./start_prod.sh  # Start production server with Gunicorn"
  echo ""
  echo -e "${YELLOW}🛠️  Useful Commands:${NC}"
  echo "   - Development: ./start_dev.sh"
  echo "   - Production: ./start_prod.sh"
  echo "   - Test database: python main.py"
  echo "   - Check services: docker-compose ps"
  echo "   - View logs: docker-compose logs -f"
  echo "   - Stop services: docker-compose down"
  echo ""
  log_success "Happy coding! 🎯"
}

# Main execution
# main - Main entry point of the script.
main() {
  display_banner

  echo -e "${CYAN}This script will create: $PROJECT_DESCRIPTION${NC}"
  echo -e "${CYAN}Total steps to execute: $TOTAL_STEPS${NC}"
  echo -e "${CYAN}Features: FastAPI + PostgreSQL + SQLAlchemy + Gunicorn${NC}"
  echo ""

  wait_for_user

  init_framework
  define_steps
  verify_prerequisites
  run_steps
  display_summary
}

# ============================================================================
# 🎬 SCRIPT ENTRY POINT
# ============================================================================
main "$@"
