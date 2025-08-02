import os
import hashlib

def verify_model(filepath):
    """Verify model file exists and has valid HDF5 signature"""
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return False
    
    # Check HDF5 file signature
    with open(filepath, 'rb') as f:
        header = f.read(4)
        if header != b'\x89HDF':
            print(f"❌ Invalid HDF5 signature in: {filepath}")
            return False
    
    print(f"✅ Verified: {filepath}")
    return True

if __name__ == "__main__":
    models_to_verify = [
        "Model_Train/rice_disease_model.h5",
        "Model_Train/wheat_inceptionv3_model.h5",
        "Model_Train/class_indices.pkl",
        "Model_Train/wheat_class_indices.pkl"
    ]
    
    all_valid = True
    for model_path in models_to_verify:
        if not verify_model(model_path):
            all_valid = False
    
    if not all_valid:
        print("❌ Some model files failed verification")
        exit(1)
    print("✅ All models verified successfully")
