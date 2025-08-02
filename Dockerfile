FROM python:3.10-slim

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# 2. Set working directory
WORKDIR /app

# 3. Copy requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy ALL application files (including models)
COPY . .

# 5. Verification script
RUN echo '\
import os\n\
import h5py\n\
print("=== Model Verification ===")\n\
\n\
def verify_model(model_path):\n\
    print(f"\\nVerifying {model_path}")\n\
    size_mb = os.path.getsize(model_path)/1024/1024\n\
    print(f"Size: {size_mb:.2f} MB")\n\
    \n\
    try:\n\
        with h5py.File(model_path, "r") as f:\n\
            if "model_weights" not in f:\n\
                raise ValueError("Missing model_weights in HDF5")\n\
            print(f"Layers found: {len(f[\'model_weights\'])}")\n\
        print("✅ Verification passed")\n\
        return True\n\
    except Exception as e:\n\
        print(f"❌ Verification failed: {str(e)}")\n\
        return False\n\
\n\
# Verify both models\n\
rice_ok = verify_model("Model_Train/rice_disease_model.h5")\n\
wheat_ok = verify_model("Model_Train/wheat_inceptionv3_model.h5")\n\
\n\
if not (rice_ok and wheat_ok):\n\
    raise RuntimeError("Model verification failed")\n\
' > verify_models.py

# 6. Run verification
RUN python verify_models.py && \
    echo "All models verified successfully"

# 7. Production configuration
ENV FLASK_ENV=production \
    TF_ENABLE_ONEDNN_OPTS=0 \
    TF_CPP_MIN_LOG_LEVEL=2

EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
