FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Configure Git LFS BEFORE copying files
RUN git lfs install

WORKDIR /app

# Copy requirements first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy ALL files (including .gitattributes)
COPY . .

# Download LFS files explicitly
RUN git lfs fetch && git lfs checkout

# Verification script
RUN echo '\
import os\n\
import h5py\n\
\n\
def verify_model(model_path):\n\
    print(f"Verifying {model_path}")\n\
    size = os.path.getsize(model_path)\n\
    print(f"Size: {size} bytes")\n\
    try:\n\
        with h5py.File(model_path, "r") as f:\n\
            print("Layers:", len(f["model_weights"]))\n\
        print("✅ Model OK")\n\
    except Exception as e:\n\
        print(f"❌ Model invalid: {str(e)}")\n\
        raise\n\
\n\
verify_model("Model_Train/rice_disease_model.h5")\n\
verify_model("Model_Train/wheat_inceptionv3_model.h5")\n\
' > verify.py

# Run verification
RUN ls -lh Model_Train/ && \
    python verify.py

# Production config
ENV FLASK_ENV=production
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
