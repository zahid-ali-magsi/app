# Use official Python 3.10 slim image
FROM python:3.10-slim as builder

# 1. Install system dependencies (added wget for debugging)
RUN apt-get update && apt-get install -y \
    libgl1 \
    git \
    git-lfs \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configure Git LFS (moved after git install)
RUN git lfs install

WORKDIR /app

# Copy only requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy everything else (excluding .git with .dockerignore)
COPY . .

# --------------------------------------------------
# Production stage
FROM python:3.10-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local
COPY --from=builder /app /app

# Model verification (fixed syntax and improved checks)
RUN python -c "\
import os, h5py; \
print('=== Model Verification ==='); \
for model in ['Model_Train/rice_disease_model.h5', 'Model_Train/wheat_inceptionv3_model.h5']: \
    assert os.path.exists(model), f'Model missing: {model}'; \
    size = os.path.getsize(model); \
    print(f'Verifying {model} ({size/1024/1024:.2f} MB)'); \
    assert size > 10*1024*1024, f'Model too small: {size} bytes'; \
    with h5py.File(model, 'r') as f: \
        assert 'model_weights' in f, 'Invalid HDF5 structure'; \
    print('✅ Verified'); \
print('\nAll models verified successfully'); \
"

# Production configuration
ENV FLASK_ENV=production \
    TF_ENABLE_ONEDNN_OPTS=0 \
    TF_CPP_MIN_LOG_LEVEL=2 \
    PYTHONUNBUFFERED=1 \
    PATH=/usr/local/bin:$PATH

# Set non-root user (fixed permissions)
RUN useradd -m appuser && \
    chown -R appuser:appuser /app && \
    chmod -R 755 /app

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Expose and run
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
