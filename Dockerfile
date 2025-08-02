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

# Create verification script
RUN echo "\
import h5py, os\n\
print('Model files:', os.listdir('Model_Train'))\n\
try:\n\
    h5py.File('Model_Train/rice_disease_model.h5', 'r')\n\
    print('Rice model verified')\n\
except Exception as e:\n\
    print(f'Rice model error: {str(e)}')\n\
" > verify_models.py

# Verify model files
RUN python verify_models.py

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
