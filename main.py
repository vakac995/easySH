"""
Railway deployment entry point for easySH backend.
This file imports the FastAPI app from the backend directory.
"""

import sys
import os
from pathlib import Path

# Ensure we're working from the correct directory
current_dir = Path(__file__).parent
backend_dir = current_dir / "backend"

# Add both directories to Python path
sys.path.insert(0, str(current_dir))
sys.path.insert(0, str(backend_dir))

print("🚀 Starting Railway deployment...")
print(f"📁 Current directory: {current_dir}")
print(f"📁 Backend directory: {backend_dir}")
print(f"🐍 Python path: {sys.path[:3]}")

# Verify backend directory exists
if not backend_dir.exists():
    print(f"❌ Backend directory not found: {backend_dir}")
    sys.exit(1)

# Verify backend/main.py exists
backend_main = backend_dir / "main.py"
if not backend_main.exists():
    print(f"❌ Backend main.py not found: {backend_main}")
    sys.exit(1)

print("✅ Backend files found")

# Import the FastAPI app from backend
try:
    print("🔄 Attempting to import FastAPI app...")
    from backend.main import app

    print("✅ Successfully imported FastAPI app from backend.main")
    print(f"📊 App type: {type(app)}")
    print(f"📊 App title: {getattr(app, 'title', 'Unknown')}")
except ImportError as e:
    print(f"❌ Failed to import FastAPI app: {e}")
    print(
        f"📋 Available modules in backend: {list((Path(__file__).parent / 'backend').glob('*.py'))}"
    )
    raise
except Exception as e:
    print(f"❌ Unexpected error importing FastAPI app: {e}")
    raise

# Export for Railway to find
__all__ = ["app"]

if __name__ == "__main__":
    print("🚀 Starting uvicorn server...")
    import uvicorn

    port = int(os.getenv("PORT", 8000))
    print(f"🌐 Starting server on 0.0.0.0:{port}")
    uvicorn.run(app, host="0.0.0.0", port=port)
