FROM python:3.10-slim

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Model verification (fixed syntax and path handling)
RUN python -c "\
import os; \
import h5py; \
print('=== Model Verification ==='); \
models = ['Model_Traain/rice_disease_model.h5', 'Model_Traain/wheat_inceptionv3_model.h5']; \
all_verified = True; \
for model in models: \
    try: \
        print(f'\nChecking: {model}'); \
        if not os.path.exists(model): \
            raise FileNotFoundError(f'Model missing: {model}'); \
        size = os.path.getsize(model); \
        print(f'Size: {size/1024/1024:.2f} MB'); \
        if size < 10*1024*1024: \
            raise ValueError(f'Model too small: {size} bytes'); \
        with h5py.File(model, 'r') as f: \
            if 'model_weights' not in f: \
                raise ValueError('Invalid HDF5 structure'); \
        print('✅ Verified'); \
    except Exception as e: \
        print(f'❌ Verification failed: {str(e)}'); \
        all_verified = False; \
if not all_verified: \
    raise RuntimeError('Model verification failed'); \
print('\nAll models verified successfully'); \
"

# Expose port (Flask default)
EXPOSE 5000

# Start the app (adjust if your entrypoint is different)
CMD ["gunicorn", "-b",