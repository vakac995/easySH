# easySH Project Generator

The project is a web-based tool for generating custom projects. It consists of a frontend built with React and Vite, and a backend powered by FastAPI and Docker.

## Project Structure

- `backend/`: Contains the FastAPI backend application.
  - `main.py`: The main application file.
  - `requirements.txt`: Python dependencies.
  - `templates/`: Jinja2 templates for generating project files.
- `frontend/`: Contains the React frontend application.
  - `src/`: The main source code for the React application.
  - `package.json`: Frontend dependencies and scripts.
- `scripts/`: Contains the original shell scripts that were used as a reference.
- `docs/`: Contains project documentation.

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
