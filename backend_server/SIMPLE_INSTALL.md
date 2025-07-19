# Simple Installation Guide

## 🚀 Easy 2-Step Installation (No Subprocess Errors!)

### Step 1: Install Core Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Install Chatbot Dependencies Manually
```bash
# Install NLP packages one by one
pip install spacy
pip install nltk  
pip install scikit-learn
pip install fuzzywuzzy
pip install python-Levenshtein
pip install yfinance

# Download required models and data
python -m spacy download en_core_web_sm
python -m nltk.downloader stopwords wordnet punkt punkt_tab

# Alternative: Quiet mode (less output)
# python -m nltk.downloader -q stopwords wordnet punkt punkt_tab
```

### Step 3: Start the Server
```bash
uvicorn main:app --host 192.168.0.101 --port 8000 --reload
```

## ✅ That's it! 

**Why this works better:**
- ✅ No subprocess errors from requirements.txt
- ✅ Each package installs independently  
- ✅ Better error handling if one package fails
- ✅ Easy to troubleshoot individual packages
- ✅ Works on all platforms (Windows, Mac, Linux)

## 🔧 If Any Package Fails:

Just skip it and install the others:

```bash
# If spacy fails, try:
pip install spacy --no-cache-dir

# If nltk fails, try:
pip install nltk --upgrade

# If scikit-learn fails, try:
pip install scikit-learn --no-binary scikit-learn

# The chatbot will still work with reduced functionality
```

## 📋 Copy-Paste Commands for Your Colleague:

**Windows:**
```cmd
pip install -r requirements.txt
pip install spacy nltk scikit-learn fuzzywuzzy python-Levenshtein yfinance
python -m spacy download en_core_web_sm
python -m nltk.downloader -q stopwords wordnet punkt punkt_tab
uvicorn main:app --host 192.168.0.101 --port 8000 --reload
```

**Mac/Linux:**
```bash
pip3 install -r requirements.txt
pip3 install spacy nltk scikit-learn fuzzywuzzy python-Levenshtein yfinance
python3 -m spacy download en_core_web_sm
python3 -m nltk.downloader -q stopwords wordnet punkt punkt_tab
uvicorn main:app --host 192.168.0.101 --port 8000 --reload
```

Much simpler and more reliable! 🎉
