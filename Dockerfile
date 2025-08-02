FROM python:3.10

# Install system dependencies
RUN apt-get update && apt-get install -y git-lfs && \
    git lfs install && \
    pip install --no-cache-dir joblib tensorflow-cpu && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all files
COPY . .

# Verify models
RUN python verify_models.py

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
