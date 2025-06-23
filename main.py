"""
Railway deployment entry point for easySH backend.
This file imports the FastAPI app from the backend directory.
"""

import sys
import os
from pathlib import Path

# Add the project root to Python path
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# Import the FastAPI app from backend
try:
    from backend.main import app
    print("✅ Successfully imported FastAPI app from backend.main")
except ImportError as e:
    print(f"❌ Failed to import FastAPI app: {e}")
    raise

# Export for Railway to find
__all__ = ['app']

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", 8000)))
