FROM python:3.10-slim

# Install system deps
RUN apt-get update && apt-get install -y \
    libgl1 \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
