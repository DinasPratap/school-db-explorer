#!/bin/bash

# Farmer Crop & Resource Optimization Database - Full Stack Run Script
# This script starts Oracle, Backend API, and Frontend

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
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/01_schema.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/02_indexes.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/03_sample_data.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/04_views.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/05_procedures.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/06_functions.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/07_triggers.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/08_queries.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/db/09_demo.sql oracle-xe:/tmp/
docker cp /Users/dinasmain/Desktop/school-db-explorer/run_all.sql oracle-xe:/tmp/

# Initialize database
echo "Initializing database..."
docker exec oracle-xe sqlplus -L system/Oracle123@//localhost:1521/XE @/tmp/run_all.sql > /dev/null 2>&1
echo "Database initialized."

# Start Backend
echo "Starting Backend API server..."
cd /Users/dinasmain/Desktop/school-db-explorer/backend
npm start &
BACKEND_PID=$!
echo "Backend started on http://localhost:3001 (PID: $BACKEND_PID)"

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
sleep 5

# Start Frontend
echo "Starting Frontend..."
cd /Users/dinasmain/Desktop/school-db-explorer/frontend
npm run dev &
FRONTEND_PID=$!
echo "Frontend started (PID: $FRONTEND_PID)"

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
