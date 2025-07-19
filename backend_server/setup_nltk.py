#!/usr/bin/env python3
"""
Post-installation setup script for NLP dependencies.
Run this after installing requirements.txt
"""

import nltk
import spacy
import subprocess
import sys

def download_nltk_data():
    """Download required NLTK datasets"""
    datasets = [
        'stopwords',
        'wordnet', 
        'punkt',
        'punkt_tab'
    ]
    
    print("📦 Downloading NLTK data...")
    
    for dataset in datasets:
        try:
            print(f"Downloading {dataset}...")
            nltk.download(dataset, quiet=True)
            print(f"✅ {dataset} downloaded successfully")
        except Exception as e:
            print(f"❌ Error downloading {dataset}: {e}")
            return False
    
    return True

def download_spacy_model():
    """Download spaCy English model"""
    print("📦 Downloading spaCy English model...")
    
    try:
        # Try to load the model first (check if already installed)
        spacy.load("en_core_web_sm")
        print("✅ spaCy model 'en_core_web_sm' already installed")
        return True
    except OSError:
        # Model not found, need to download
        pass
    
    try:
        # Download the model using spaCy's download command
        result = subprocess.run([
            sys.executable, "-m", "spacy", "download", "en_core_web_sm"
        ], capture_output=True, text=True, check=True)
        
        print("✅ spaCy model 'en_core_web_sm' downloaded successfully")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error downloading spaCy model: {e}")
        print("🔧 Try running manually: python -m spacy download en_core_web_sm")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def verify_installations():
    """Verify all installations are working"""
    print("🔍 Verifying installations...")
    
    # Test NLTK
    try:
        import nltk
        nltk.data.find('tokenizers/punkt')
        print("✅ NLTK working correctly")
    except Exception as e:
        print(f"❌ NLTK verification failed: {e}")
        return False
    
    # Test spaCy
    try:
        import spacy
        nlp = spacy.load("en_core_web_sm")
        doc = nlp("Test sentence")
        print("✅ spaCy working correctly")
    except Exception as e:
        print(f"❌ spaCy verification failed: {e}")
        return False
    
    # Test other packages
    try:
        import fuzzywuzzy
        import sklearn
        print("✅ All NLP packages working correctly")
    except Exception as e:
        print(f"❌ Package verification failed: {e}")
        return False
    
    return True

def main():
    """Main setup function"""
    print("🚀 Starting NLP setup...")
    print("=" * 50)
    
    # Download NLTK data
    nltk_success = download_nltk_data()
    print()
    
    # Download spaCy model
    spacy_success = download_spacy_model()
    print()
    
    if nltk_success and spacy_success:
        # Verify everything works
        if verify_installations():
            print("🎉 All NLP dependencies set up successfully!")
            print("✅ Your chatbot is ready to use!")
        else:
            print("⚠️ Setup completed but verification failed")
            return False
    else:
        print("❌ Setup failed. Please check the errors above.")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
