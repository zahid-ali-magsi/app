FROM python:3.10-slim

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Model verification (fixed syntax and path handling)
RUN python verify_models.py

# Expose port (Flask default)
EXPOSE 5000

# Start the app (adjust if your entrypoint is different)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]