"""
Railway deployment entry point for easySH backend.
This file imports the FastAPI app from the backend directory.
"""

import sys
from pathlib import Path

# Add the project root to Python path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# Import the FastAPI app from backend
from backend.main import app

# Export for Railway to find
__all__ = ['app']
