#!/bin/bash
# Docker production startup script

echo "🐳 Starting Docker production server..."

# Wait for database to be ready
until PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\q"; do
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
    --log-level info