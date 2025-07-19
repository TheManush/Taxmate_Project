# Installation Guide - Fix for Subprocess Errors

## 🚨 Quick Fix for "subprocess error"

If you're getting subprocess errors when running `pip install -r requirements.txt`, follow these steps:

### Option 1: Step-by-Step Installation (Recommended)

```bash
# 1. Install basic packages first
pip install fastapi uvicorn sqlalchemy psycopg2 pandas numpy

# 2. Install NLP packages separately
pip install spacy nltk scikit-learn fuzzywuzzy python-Levenshtein

# 3. Install remaining packages
pip install -r requirements.txt

# 4. Download NLP models
python setup_nltk.py
```

### Option 2: Alternative Installation Method

```bash
# Install everything except problematic packages
pip install --no-deps -r requirements.txt

# Then install missing dependencies manually
pip install spacy>=3.7.0
pip install nltk>=3.8.1
pip install fuzzywuzzy>=0.18.0
pip install python-Levenshtein>=0.21.1
pip install scikit-learn>=1.3.0

# Download models
python -m spacy download en_core_web_sm
python setup_nltk.py
```

### Option 3: Using Conda (If Available)

```bash
# Create conda environment
conda create -n taxmate python=3.9
conda activate taxmate

# Install packages via conda (more reliable)
conda install -c conda-forge spacy nltk scikit-learn pandas numpy
conda install -c conda-forge fuzzywuzzy python-levenshtein

# Install remaining with pip
pip install fastapi uvicorn sqlalchemy psycopg2

# Download models
python -m spacy download en_core_web_sm
python setup_nltk.py
```

## 🔍 Common Subprocess Error Causes

### 1. **Direct URL Dependencies**
**Problem**: Lines like this cause issues:
```
en-core-web-sm @ https://github.com/explosion/spacy-models/...
```

**Solution**: We've removed this from requirements.txt and moved it to the setup script.

### 2. **Platform-Specific Packages**
**Problem**: Some packages have different names on Windows/Mac/Linux

**Solution**: Use these platform-specific commands:

#### Windows:
```cmd
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
python setup_nltk.py
```

#### macOS:
```bash
pip3 install --upgrade pip setuptools wheel
pip3 install -r requirements.txt
python3 setup_nltk.py
```

#### Linux:
```bash
sudo apt-get update
sudo apt-get install python3-pip python3-dev
pip3 install --upgrade pip setuptools wheel
pip3 install -r requirements.txt
python3 setup_nltk.py
```

### 3. **Permission Issues**
**Problem**: Permission denied errors

**Solution**: 
```bash
# Use --user flag
pip install --user -r requirements.txt

# Or create virtual environment
python -m venv taxmate_env
# Windows:
taxmate_env\Scripts\activate
# macOS/Linux:
source taxmate_env/bin/activate

pip install -r requirements.txt
```

### 4. **Outdated pip/setuptools**
**Problem**: Old pip version causing issues

**Solution**:
```bash
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

## 🛠️ Debugging Steps

### Step 1: Check Python Version
```bash
python --version
# Should be Python 3.7 or higher
```

### Step 2: Check pip Version
```bash
pip --version
# Should be pip 21.0 or higher
```

### Step 3: Test Individual Packages
```bash
# Test each problematic package individually
pip install spacy
pip install nltk
pip install scikit-learn
pip install fuzzywuzzy
```

### Step 4: Check for Conflicts
```bash
pip check
# Shows any dependency conflicts
```

### Step 5: Clean Installation
```bash
# Remove all packages and reinstall
pip freeze > installed_packages.txt
pip uninstall -r installed_packages.txt -y
pip install -r requirements.txt
```

## 📋 Minimal Requirements (If Still Having Issues)

If you continue having problems, install only the essential packages:

```bash
# Core FastAPI requirements
pip install fastapi==0.115.12
pip install uvicorn==0.34.2
pip install sqlalchemy==2.0.41
pip install psycopg2==2.9.10
pip install pydantic==2.11.4

# Basic NLP (without advanced features)
pip install nltk>=3.8.1

# Run basic setup
python -c "import nltk; nltk.download('punkt')"
```

**Note**: The chatbot will work with reduced functionality but core features remain operational.

## ✅ Verification Commands

After successful installation, verify everything works:

```bash
# Test imports
python -c "import fastapi, uvicorn, spacy, nltk, sklearn"

# Test spaCy model
python -c "import spacy; nlp = spacy.load('en_core_web_sm'); print('spaCy working!')"

# Test NLTK data
python -c "import nltk; nltk.data.find('tokenizers/punkt'); print('NLTK working!')"

# Run the setup verification
python setup_nltk.py
```

## 🚀 Start the Server

Once installation is complete:

```bash
# Navigate to backend directory
cd backend_server

# Start the server
uvicorn main:app --host 192.168.0.101 --port 8000 --reload
```

## 📞 Still Having Issues?

If you're still experiencing problems:

1. **Share the exact error message** - Copy the full error output
2. **Check your Python version** - Must be 3.7+
3. **Try the minimal installation** - Use the reduced requirements above
4. **Use virtual environment** - Isolates dependencies
5. **Check internet connection** - Some packages download additional data

## 💡 Pro Tips

- **Always use virtual environments** for Python projects
- **Keep pip updated** with `pip install --upgrade pip`
- **Install packages one by one** if batch installation fails
- **Use conda** if available - often more reliable than pip for scientific packages
- **Check firewall/antivirus** - Sometimes blocks package downloads

---

**Updated**: July 2025  
**Tested on**: Windows 10/11, macOS 12+, Ubuntu 20.04+
