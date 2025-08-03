import os
from tensorflow.keras.models import load_model
import h5py

print('=== Model Verification ===')
models = [
    'Model_Train/rice_disease_model.h5',
    'Model_Train/wheat_inceptionv3_model.h5'
]
all_verified = True
for model in models:
    try:
        print(f'\nChecking: {model}')
        if not os.path.exists(model):
            raise FileNotFoundError(f'Model missing: {model}')
        size = os.path.getsize(model)
        print(f'Size: {size/1024/1024:.2f} MB')
        if size < 10*1024*1024:
            raise ValueError(f'Model too small: {size} bytes')
        with h5py.File(model, 'r') as f:
            if 'model_weights' not in f:
                raise ValueError('Invalid HDF5 structure')
        print('✅ Verified')
    except Exception as e:
        print(f'❌ Verification failed: {str(e)}')
        all_verified = False
if not all_verified:
    raise RuntimeError('Model verification failed')
print('\nAll models verified successfully')
