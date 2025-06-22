# From Scripts to a Web Application: The Architecture of easySH

This document outlines the final architecture of the easySH project generator, which evolved from a set of shell scripts into a modern web application.

### 1. Core Concept: Template-Based Generation

The initial shell scripts (`setup_project.sh`, `createViteApp.sh`, `createModuleConfigSystem.sh`) were analyzed to extract their core logic. Instead of executing these scripts on a server, we adopted a more secure and flexible approach: a template-based generation engine.

The system uses Jinja2 as its templating engine. The entire file structure of a target project (both backend and frontend) is stored as a series of `.jinja2` templates in the `backend/templates` directory.

### 2. The Generation Workflow

The process of creating a new project is as follows:

1.  **Configuration via UI**: The user interacts with a gamified, step-by-step wizard on the frontend. This wizard gathers all the necessary configuration options, such as project name, database credentials, and desired features.

2.  **API Request**: The collected configuration is bundled into a single JSON object and sent to the backend via a POST request to the `/generate-project/` endpoint.

3.  **Backend Processing**: The FastAPI backend receives the JSON configuration. It then uses this data to render the Jinja2 templates, creating the complete source code for the new project in memory.

4.  **ZIP Archive Creation**: The generated files and directories are packaged into a single, compressed ZIP archive.

5.  **Download**: The backend streams the ZIP archive back to the user, who can then download, extract, and run their custom-configured project.

### 3. Technology Stack

-   **Backend**:
    -   **Framework**: FastAPI (Python)
    -   **Templating**: Jinja2
    -   **Deployment**: Docker and Docker Compose for a containerized, production-ready environment.

-   **Frontend**:
    -   **Framework**: React (with Vite for tooling)
    -   **Language**: JavaScript (with JSX)
    -   **Styling**: Tailwind CSS
    -   **Animation**: Framer Motion
    -   **State Management**: React Hooks and Context API

### 4. Key Architectural Features

-   **Decoupled Frontend and Backend**: The frontend is a standalone React application that communicates with the backend via a REST API. This separation of concerns allows for independent development and deployment.

-   **Gamified User Experience**: The frontend features a multi-step wizard with gamification elements like a progress bar, achievements, and a "power level" to make the configuration process more engaging.

-   **Scalable Template System**: The Jinja2 template structure makes it easy to add new features, options, or even entire project types in the future by simply adding new templates and updating the configuration options.

-   **Post-Generation Setup Script**: The generated project includes a `setup_environment.sh` script to automate initial setup tasks, such as creating a virtual environment and installing dependencies, ensuring a smooth onboarding experience for the user.
