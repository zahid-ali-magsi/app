FROM python:3.10

# Install system dependencies
RUN apt-get update && apt-get install -y git-lfs && git lfs install

WORKDIR /app

# Copy all files (including verify_models.py)
COPY . .

# Verify models before installation
RUN python verify_models.py && \
    pip install -r requirements.txt

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
