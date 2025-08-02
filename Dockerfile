FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies first (for caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Verify installations
RUN python -c "from flask_mail import Mail; print('Flask-Mail successfully imported')"

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
