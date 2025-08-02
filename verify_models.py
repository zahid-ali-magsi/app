import os
import joblib
from tensorflow.keras.models import load_model

def verify_h5_model(filepath):
    """Verify HDF5 model file"""
    try:
        load_model(filepath)  # Try loading the model
        print(f"✅ Valid HDF5 model: {filepath}")
        return True
    except Exception as e:
        print(f"❌ Invalid HDF5 model {filepath}: {str(e)}")
        return False

def verify_pkl_file(filepath):
    """Verify pickle file can be loaded"""
    try:
        data = joblib.load(filepath)
        if not isinstance(data, dict):
            print(f"❌ PKL file {filepath} should contain a dictionary")
            return False
        print(f"✅ Valid PKL file: {filepath}")
        return True
    except Exception as e:
        print(f"❌ Invalid PKL file {filepath}: {str(e)}")
        return False

if __name__ == "__main__":
    # Files to verify
    files_to_verify = {
        "Model_Train/rice_disease_model.h5": verify_h5_model,
        "Model_Train/wheat_inceptionv3_model.h5": verify_h5_model,
        "Model_Train/class_indices.pkl": verify_pkl_file,
        "Model_Train/wheat_class_indices.pkl": verify_pkl_file
    }
    
    all_valid = True
    for filepath, verifier in files_to_verify.items():
        if not os.path.exists(filepath):
            print(f"❌ File not found: {filepath}")
            all_valid = False
            continue
            
        if not verifier(filepath):
            all_valid = False
    
    if not all_valid:
        print("❌ Some files failed verification")
        exit(1)
    print("✅ All files verified successfully")
