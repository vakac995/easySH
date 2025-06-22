# easySH Project Generator

The project is a web-based tool for generating custom projects. It consists of a frontend built with HTML, CSS, and vanilla JavaScript, and a backend powered by FastAPI.

## Project Structure

- `backend/`: Contains the FastAPI backend application.
  - `main.py`: The main application file.
  - `requirements.txt`: Python dependencies.
  - `templates/`: Jinja2 templates for generating project files.
- `frontend/`: Contains the frontend application.
  - `index.html`: The main HTML file.
- `scripts/`: Contains the original shell scripts that were used as a reference.
- `docs/`: Contains project documentation.

## How to Run

1.  **Set up the Python environment:**

    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    pip install -r backend/requirements.txt
    ```

2.  **Start the backend server:**

    ```bash
    uvicorn backend.main:app --reload
    ```

3.  **Open the frontend:**

    Open the `frontend/index.html` file in web browser.

Use this web interface to configure and generate custom projects.
