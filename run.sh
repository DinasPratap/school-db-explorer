#!/bin/bash

# Farmer Crop & Resource Optimization Database - Full Stack Run Script
# This script starts Oracle, Backend API, and Frontend

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "  AgriOptima - Full Stack Application"
echo "=========================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if Oracle container exists
if docker ps -a | grep -q oracle-xe; then
    echo "Oracle container exists."
    if docker ps | grep -q oracle-xe; then
        echo "Oracle container is already running."
    else
        echo "Starting Oracle container..."
        docker start oracle-xe
        echo "Waiting for database to be ready..."
        sleep 30
    fi
else
    echo "Creating and starting Oracle container..."
    docker run -d -p 1521:1521 -p 8080:8080 -e ORACLE_PASSWORD=Oracle123 --name oracle-xe gvenzl/oracle-xe:21-slim
    echo "Waiting for database to initialize (this takes 30-60 seconds)..."
    sleep 45
fi

# Copy SQL files to container
echo "Copying SQL files to container..."
docker cp "$SCRIPT_DIR/db/01_schema.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/02_indexes.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/03_sample_data.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/04_views.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/05_procedures.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/06_functions.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/07_triggers.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/08_queries.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/db/09_demo.sql" oracle-xe:/tmp/
docker cp "$SCRIPT_DIR/run_all.sql" oracle-xe:/tmp/

# Initialize database
echo "Initializing database..."
docker exec oracle-xe sqlplus -L system/Oracle123@//localhost:1521/XE @/tmp/run_all.sql > /dev/null 2>&1
echo "Database initialized."

# Start Backend
echo "Starting Backend API server..."
cd "$SCRIPT_DIR/backend"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
fi

npm start &
BACKEND_PID=$!
echo "Backend started on http://localhost:3001 (PID: $BACKEND_PID)"

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
sleep 8

# Check if backend is still running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "ERROR: Backend failed to start. Check logs above."
    echo "Possible issues:"
    echo "  - Oracle database not ready"
    echo "  - Missing dependencies (run: cd backend && npm install)"
    echo "  - Port 3001 already in use"
    exit 1
fi

echo "Backend is running successfully."

# Start Frontend
echo "Starting Frontend..."
cd "$SCRIPT_DIR/frontend"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

npm run dev &
FRONTEND_PID=$!
echo "Frontend started (PID: $FRONTEND_PID)"

# Wait for frontend to be ready
echo "Waiting for frontend to be ready..."
sleep 5

# Check if frontend is still running
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo "ERROR: Frontend failed to start. Check logs above."
    echo "Possible issues:"
    echo "  - Missing dependencies (run: cd frontend && npm install)"
    echo "  - Port 8081 already in use"
    exit 1
fi

echo "Frontend is running successfully."

echo ""
echo "=========================================="
echo "  Application Running!"
echo "=========================================="
echo ""
echo "Frontend: http://localhost:8081"
echo "Backend API: http://localhost:3001"
echo "Oracle Database: localhost:1521/XE"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Wait for user to stop
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT TERM
wait
