FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1 \
    git \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Configure Git LFS
RUN git lfs install

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application (including .gitattributes)
COPY . .

# Verify model files
RUN python -c "
import h5py, os
print('Model files:', os.listdir('Model_Train'))
try:
    h5py.File('Model_Train/rice_disease_model.h5', 'r')
    print('Rice model verified')
except Exception as e:
    print(f'Rice model error: {str(e)}')
"

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
