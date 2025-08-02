# Use official Python 3.10 slim image
FROM python:3.10-slim as builder

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Configure Git LFS
RUN git lfs install

WORKDIR /app

# Copy only requirements first for caching
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Copy everything else
COPY . .

# Fetch LFS files
RUN git lfs fetch && git lfs checkout

# --------------------------------------------------
# Production stage
FROM python:3.10-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

# Ensure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH

# Model verification
RUN python -c "\
import os, h5py; \
print('=== Model Verification ==='); \
for model in ['Model_Train/rice_disease_model.h5', 'Model_Train/wheat_inceptionv3_model.h5']: \
    print(f'\nVerifying {model}'); \
    size = os.path.getsize(model); \
    assert size > 10*1024*1024, f'Model too small: {size} bytes'; \
    with h5py.File(model, 'r') as f: \
        assert 'model_weights' in f, 'Invalid HDF5 structure'; \
    print(f'✅ Verified ({size/1024/1024:.2f} MB)'; \
print('\nAll models verified successfully'); \
"

# Production configuration
ENV FLASK_ENV=production \
    TF_ENABLE_ONEDNN_OPTS=0 \
    TF_CPP_MIN_LOG_LEVEL=2 \
    PYTHONUNBUFFERED=1

# Set non-root user
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Expose and run
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"]
