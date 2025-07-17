#!/usr/bin/env python3
"""
Setup script to download required NLTK data after pip installation.
Run this once after installing requirements.txt
"""

import nltk
import sys

def download_nltk_data():
    """Download required NLTK datasets"""
    datasets = [
        'stopwords',
        'wordnet', 
        'punkt',
        'punkt_tab'
    ]
    
    print("Downloading NLTK data...")
    
    for dataset in datasets:
        try:
            print(f"Downloading {dataset}...")
            nltk.download(dataset, quiet=True)
            print(f"✅ {dataset} downloaded successfully")
        except Exception as e:
            print(f"❌ Error downloading {dataset}: {e}")
            return False
    
    print("🎉 All NLTK data downloaded successfully!")
    return True

if __name__ == "__main__":
    success = download_nltk_data()
    sys.exit(0 if success else 1)
