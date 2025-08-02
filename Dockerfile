FROM python:3.10-slim

# System dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Initialize Git LFS before copying files
RUN git lfs install

WORKDIR /app

# Copy ONLY requirements first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy everything else
COPY . .

# Verify LFS files were properly pulled
RUN git lfs pull && \
    ls -lh Model_Train/ && \
    file Model_Train/rice_disease_model.h5 && \
    python -c "
import h5py
h5py.File('Model_Train/rice_disease_model.h5', 'r')
print('Model verification successful')
"

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
