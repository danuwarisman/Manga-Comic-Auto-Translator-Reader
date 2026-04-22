#!/bin/bash

# ==============================================
# ScanBridge - Automated Setup Script (Linux/macOS)
# ==============================================

set -e  # Hentikan skrip jika ada error

# --- Fungsi untuk mencetak pesan dengan warna ---
print_success() { echo -e "\033[0;32m[✓] $1\033[0m"; }
print_info()   { echo -e "\033[0;34m[→] $1\033[0m"; }
print_error()  { echo -e "\033[0;31m[✗] $1\033[0m"; }
print_header() { echo -e "\n\033[1;36m>>> $1\033[0m"; }

# --- 0. Deteksi Sistem Operasi ---
print_header "Memeriksa Sistem Operasi..."
OS_TYPE=$(uname)
if [[ "$OS_TYPE" == "Linux" ]]; then
    print_success "Sistem Linux terdeteksi."
    INSTALL_CMD="sudo apt install -y"
    PIP_CMD="pip3"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    print_success "Sistem macOS terdeteksi."
    # Periksa Homebrew
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew tidak ditemukan. Silakan instal dari https://brew.sh/"
        exit 1
    fi
    INSTALL_CMD="brew install"
    PIP_CMD="pip3"
else
    print_error "Sistem operasi tidak didukung. Gunakan setup.ps1 untuk Windows."
    exit 1
fi

# --- 1. Periksa & Instal Python 3.10+ ---
print_header "Memeriksa Python..."
if ! command -v python3 &> /dev/null; then
    print_info "Python 3 tidak ditemukan. Menginstal..."
    if [[ "$OS_TYPE" == "Linux" ]]; then
        sudo apt update
        sudo apt install -y python3 python3-pip python3-venv
    else
        brew install python@3.10
    fi
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
print_success "Python $PYTHON_VERSION terinstal."

# --- 2. Periksa & Instal Flutter SDK ---
print_header "Memeriksa Flutter SDK..."
if ! command -v flutter &> /dev/null; then
    print_info "Flutter SDK tidak ditemukan di PATH."
    echo "Silakan unduh dan instal Flutter SDK secara manual dari:"
    echo "https://docs.flutter.dev/get-started/install"
    echo "Setelah itu, pastikan direktori 'flutter/bin' ada di PATH Anda."
    read -p "Tekan Enter setelah Flutter terinstal dan PATH sudah diatur..."
else
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter terinstal: $FLUTTER_VERSION"
    flutter doctor
fi

# --- 3. Setup Virtual Environment Python ---
print_header "Menyiapkan Virtual Environment Python..."
cd backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
    print_success "Virtual environment 'venv' dibuat."
else
    print_success "Virtual environment 'venv' sudah ada."
fi
source venv/bin/activate
print_info "Virtual environment diaktifkan."

# --- 4. Instal Dependensi Python ---
print_header "Menginstal Dependensi Python..."
pip install --upgrade pip

# Daftar pustaka yang dibutuhkan (sama seperti di dokumen)
REQUIREMENTS=(
    "fastapi[standard]"
    "ultralytics"
    "manga-ocr"
    "comicpy"
    "opencv-python"
    "Pillow"
    "torch"
    "torchvision"
    "torchaudio"
)

for pkg in "${REQUIREMENTS[@]}"; do
    print_info "Memeriksa $pkg..."
    if pip show "${pkg%%[*}" > /dev/null 2>&1; then
        print_success "$pkg sudah terinstal."
    else
        print_info "Menginstal $pkg..."
        pip install "$pkg"
    fi
done

print_success "Semua dependensi Python berhasil diproses."
deactivate  # Keluar dari virtual environment
cd ..

# --- 5. Setup Flutter Frontend ---
print_header "Menyiapkan Flutter Frontend..."
cd frontend
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependensi Flutter berhasil diinstal."
else
    print_error "Gagal menjalankan 'flutter pub get'."
fi
cd ..

# --- 6. Periksa Model AI (Informasi Saja) ---
print_header "Model AI yang Perlu Diunduh (Akan Otomatis Saat Pertama Digunakan)"
echo "Model-model berikut akan diunduh otomatis oleh library saat aplikasi dijalankan:"
echo "- YOLOv8 (deteksi balon)  : ~50 MB"
echo "- MangaOCR (pembaca teks) : ~200-300 MB"
echo "- LaMa (penghapus teks)   : ~300-500 MB"
echo "- Sugoi Translator        : ~3-5 GB (Opsional, bisa gunakan Google Translate gratis)"

print_success "=============================================="
print_success "Setup ScanBridge Selesai!"
print_success "=============================================="
echo "Langkah selanjutnya:"
echo "1. Buka terminal baru, masuk ke folder 'backend', dan aktifkan venv:"
echo "   cd backend && source venv/bin/activate"
echo "2. Jalankan server backend: uvicorn server.main:app --reload"
echo "3. Buka terminal lain, masuk ke folder 'frontend', dan jalankan:"
echo "   flutter run"