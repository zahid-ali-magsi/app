# Use official Python 3.10 slim image
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Configure Git LFS
RUN git lfs install

# Set working directory
WORKDIR /app

# Copy requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create verification script
RUN echo '\
import os\n\
import h5py\n\
\n\
def verify_model(model_path):\n\
    print(f"Verifying {model_path}")\n\
    \n\
    # Check file exists\n\
    if not os.path.exists(model_path):\n\
        raise FileNotFoundError(f"Model file not found: {model_path}")\n\
    \n\
    # Check file size\n\
    size_mb = os.path.getsize(model_path) / (1024 * 1024)\n\
    print(f"Model size: {size_mb:.2f} MB")\n\
    if size_mb < 1:\n\
        raise ValueError("Model file too small (corrupted?)")\n\
    \n\
    # Verify HDF5 structure\n\
    try:\n\
        with h5py.File(model_path, "r") as f:\n\
            if "model_weights" not in f:\n\
                raise ValueError("Invalid HDF5 structure")\n\
        print("✅ Model verification successful")\n\
    except Exception as e:\n\
        raise ValueError(f"Model verification failed: {str(e)}")\n\
\n\
# Verify both models\n\
verify_model("Model_Train/rice_disease_model.h5")\n\
verify_model("Model_Train/wheat_inceptionv3_model.h5")\n\
' > verify_models.py

# Run verifications
RUN git lfs pull && \
    # List files to verify they were pulled
    ls -lh Model_Train/ && \
    # Check file types
    file Model_Train/rice_disease_model.h5 && \
    file Model_Train/wheat_inceptionv3_model.h5 && \
    # Run Python verification
    python verify_models.py

# Set environment variables
ENV FLASK_ENV=production \
    TF_ENABLE_ONEDNN_OPTS=0 \
    TF_CPP_MIN_LOG_LEVEL=2

# Expose port
EXPOSE 8080

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
