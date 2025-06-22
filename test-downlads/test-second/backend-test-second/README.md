# A robust backend service.

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
- **PgAdmin:** http://localhost:5050 (testsecond@testsecond.com / )

## 📡 API Endpoints

- `GET /` - Health check and welcome message
- `GET /health` - Detailed health check with database status
- `GET /users` - Get all users
- `GET /users/{username}` - Get specific user
- `GET /users/{username}/posts` - Get user's posts
- `POST /users` - Create new user

## 🏗️ Project Structure

```
test-second/
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
- **Database:** test_second_db
- **Username:** test_second_db_user
- **Password:** 

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
docker-compose exec postgres psql -U test_second_db_user -d test_second_db
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
DB_NAME=test_second_db
DB_USER=test_second_db_user
DB_PASSWORD=

# PgAdmin settings
PGADMIN_EMAIL=testsecond@testsecond.com
PGADMIN_PASSWORD=
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