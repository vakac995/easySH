# easySH Project Generator

The project is a web-based tool for generating custom projects. It consists of a frontend built with React and Vite, and a backend powered by FastAPI and Docker.

## Quick Start

### Running the Application

1. **Start the Backend:**

   ```bash
   cd backend
   python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
   ```

2. **Start the Frontend:**

   ```bash
   cd frontend
   npm install
   npm run dev
   ```

3. **Access the Application:**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8000

## What's New in Version 1.2.1

🔧 **CORS Fix**: Resolved GitHub Pages ↔ Railway communication issues  
✅ **Production Ready**: Frontend and backend now communicate seamlessly in production  
🧪 **Testing Tools**: Added development mode CORS connectivity testing  

## What's New in Version 1.2.0

✅ **Enhanced Configuration**: Frontend now collects all backend-required fields
✅ **Extended Wizard**: Added database configuration step for complete setup  
✅ **API Synchronization**: Fixed frontend-backend configuration mismatch  
✅ **Better UX**: Improved form validation and detailed configuration review

## Features

- **Guided Project Setup**: Step-by-step wizard with gamification
- **Full Stack Projects**: Complete FastAPI backend + React frontend
- **Production Ready**: Docker configurations and deployment scripts
- **One-Click Download**: Get a complete, ready-to-run project in seconds
- **Best Practices**: Latest libraries and FiBank coding standards

## Generated Project Structure

```
project-name/
├── project-name-backend/     # FastAPI backend with PostgreSQL
├── project-name-frontend/    # React + Vite frontend with Tailwind
└── setup_environment.sh     # One-command setup script
```

## Documentation

📖 **[Complete Documentation](docs/README.md)** - Comprehensive guides and architecture documentation

### Quick Links

- **[Project Overview](docs/01-project-overview/README.md)** - What easySH is and why it exists
- **[Development Guide](docs/05-development/development-guide.md)** - Complete setup and development workflow
- **[System Architecture](docs/02-architecture/system-architecture.md)** - How the system works
- **[Changelog](docs/06-fixes-and-improvements/changelog.md)** - Recent updates and improvements

## Project Structure

- `backend/`: Contains the FastAPI backend application.
  - `main.py`: The main application file.
  - `requirements.txt`: Python dependencies.
  - `templates/`: Jinja2 templates for generating project files.
- `frontend/`: Contains the React frontend application.
  - `src/`: The main source code for the React application.
  - `package.json`: Frontend dependencies and scripts.
- `scripts/`: Contains the original shell scripts that were used as a reference.
- `docs/`: Contains organized project documentation (see [Documentation](#documentation)).

## How to Run

### Backend

The backend is designed to be run with Docker.

1.  **Build and run the Docker containers:**

    ```bash
    docker-compose up --build
    ```

2.  The backend will be available at `http://localhost:8000`.

### Frontend

1.  **Navigate to the frontend directory:**

    ```bash
    cd frontend
    ```

2.  **Install dependencies:**

    ```bash
    npm install
    ```

3.  **Start the development server:**

    ```bash
    npm run dev
    ```

4.  The frontend will be available at `http://localhost:5173`.

Use this web interface to configure and generate custom projects.

## Contributing

This project is designed for FiBank Bulgaria's internal use. See the [Development Guide](docs/05-development/development-guide.md) for detailed information about working with the codebase.

## Version History

- **v1.2.0**: Enhanced configuration synchronization and extended wizard
- **v1.1.0**: Complete gamification system and UI improvements
- **v1.0.0**: Initial release with core functionality

See [Changelog](docs/06-fixes-and-improvements/changelog.md) for detailed version history.
