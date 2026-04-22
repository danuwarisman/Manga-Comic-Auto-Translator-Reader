
---

# 📘 DOKUMEN PROYEK: "Manga/Comic Auto-Translator Reader"

---

## 1. 📋 Ringkasan Eksekutif & Visi

**Visi:**
Membangun aplikasi pembaca komik yang dapat menerjemahkan teks secara otomatis dari bahasa Jepang/Korea ke Bahasa Indonesia (atau bahasa lain), berjalan efisien di **Mobile (Android/iOS)** dan **Desktop (Windows/macOS/Linux)**.

**Tujuan Utama (Goals):**
1.  **Menciptakan Portofolio Teknis:** Menunjukkan kemampuan mengintegrasikan teknologi AI modern (YOLO, OCR, Inpainting) ke dalam aplikasi konsumen.
2.  **Menyelesaikan Masalah Pribadi & Komunitas:** Mempermudah akses bacaan komik *raw* tanpa harus menunggu *scanlation* manual.
3.  **Belajar Arsitektur Hybrid:** Mengimplementasikan komunikasi antara Frontend (Flutter) dan Backend AI (Python).

**Batasan Proyek (Non-Goals untuk Versi 1.0):**
- ❌ Tidak ada fitur sosial (share, like, comment).
- ❌ Tidak ada sinkronisasi cloud (Google Drive/iCloud).
- ❌ Tidak mendukung video atau animasi (GIF).

---

## 2. 🛠️ Spesifikasi Teknis & Teknologi yang Disepakati

**Ini adalah aturan main yang tidak boleh dilanggar tanpa diskusi tim.**

### A. Arsitektur Utama: **Hybrid Offline-First**
Aplikasi ini terbagi menjadi dua komponen utama yang berkomunikasi melalui **HTTP Lokal (127.0.0.1)** .

| Komponen | Teknologi Wajib | Alasan / Keunggulan |
| :--- | :--- | :--- |
| **Frontend (UI)** | **Flutter** (Dart) | UI konsisten di semua platform, performa animasi halus saat *scrolling* komik. |
| **Backend AI** | **Python 3.10+** | Ekosistem AI (PyTorch, MangaOCR) paling matang. Hanya diakses lokal. |
| **Komunikasi** | **REST API** (FastAPI) | Python backend akan membuka server lokal di port 5000. Flutter akan `POST` gambar dan menerima JSON hasil terjemahan. |

### B. Library & Model AI Spesifik (Backend Python)

| Fungsi | Library / Model | Catatan / Aturan Pakai |
| :--- | :--- | :--- |
| Deteksi Balon | **YOLOv8** | Harus menggunakan model yang sudah di-*fine-tune* untuk dataset manga (contoh: `yolov8m-manga.pt`). |
| OCR | **MangaOCR** | **Wajib**. Dilarang menggunakan Tesseract karena tidak akurat untuk vertikal. |
| Terjemahan | **Sugoi Translator** (Offline) | Prioritas utama agar aplikasi tetap **Gratis & Privasi Terjaga**. |
| *Fallback* Terjemahan | DeepL API / Google Translate | Hanya sebagai opsi cadangan jika user menginginkan hasil lebih natural (opsi *beta*). |
| Inpainting | **LaMa** (lama-cleaner) | Menggunakan *mask* dari hasil deteksi YOLO untuk menghapus teks asli. |
| Manajemen File | **comicpy** | Untuk ekstraksi dan kompresi ulang file CBZ/ZIP. |

### C. Aturan Paket & Dependensi
- **Python Backend:** Harus menyediakan `requirements.txt` yang selalu *up-to-date*.
- **Flutter Frontend:** Harus menggunakan `pubspec.yaml` standar. Hindari *plugin* yang tidak perlu untuk menjaga ukuran APK tetap kecil.

---

## 3. 📁 Struktur Folder Proyek (Wajib Diikuti)

Untuk memudahkan kolaborasi, struktur repositori harus seperti ini:

```text
scanbridge/
│
├── frontend/                 # Folder Kode Flutter
│   ├── lib/
│   │   ├── screens/          # UI Pages (Home, Reader, Settings)
│   │   ├── services/         # Kode untuk panggil API lokal Python
│   │   └── widgets/          # Komponen reusable
│   └── pubspec.yaml
│
├── backend/                  # Folder Kode Python
│   ├── core/                 # Logika utama (YOLO, OCR, Translate)
│   ├── server/               # Kode FastAPI (main.py)
│   ├── models/               # Tempat simpan file model AI (.pt, .onnx)
│   └── requirements.txt
│
├── docs/                     # Dokumentasi tambahan
├── assets/                   # Ikon, font, gambar statis
└── README.md                 # Dokumen yang sedang kamu baca ini
```

---

## 4. 🤝 Aturan Kolaborasi & Kontribusi

**Prinsip: Semua perubahan melalui Pull Request (PR). Dilarang push langsung ke branch `main`.**

### A. Alur Kerja Git (Branching Strategy)

1.  **`main`**: Branch utama. Kode di sini **harus selalu bisa dijalankan** dan bebas error.
2.  **`develop`**: Branch untuk integrasi fitur-fitur baru sebelum naik ke `main`.
3.  **`feature/nama-fitur`**: Setiap anggota membuat branch dari `develop` untuk mengerjakan tugas spesifik.
    - Contoh: `feature/deteksi-balon-yolo`
    - Contoh: `feature/ui-reader-scroll`

### B. Standar Penulisan Commit Message

Gunakan format: `[Tipe] Pesan singkat`
- `[FEAT]` : Menambah fitur baru.
- `[FIX]` : Memperbaiki bug.
- `[DOCS]` : Update dokumentasi.
- `[STYLE]` : Perbaikan tampilan/UI tanpa ubah logika.

*Contoh:* `[FEAT] Menambahkan endpoint /translate di FastAPI`

### C. Standar Kode

- **Python:** Wajib menggunakan **Black** formatter.
- **Flutter/Dart:** Wajib menggunakan **`dart format`** .
- Setiap fungsi utama **harus** disertai *docstring* atau komentar singkat.

---

## 5. 🎯 Target Pencapaian (Milestones)

Untuk menjaga agar proyek tidak melebar, kita bagi menjadi 3 fase:

### 🟢 **Fase 1: MVP (Minimum Viable Product)** - *Deadline: 4 Minggu*
- **Backend:** Script Python bisa menerima 1 gambar -> Mengembalikan 1 gambar hasil terjemahan (via command line).
- **Frontend:** Aplikasi Flutter statis dengan tombol "Pilih Gambar".
- **Integrasi:** Flutter bisa memanggil script Python (via `Process.run`) dan menampilkan hasilnya di layar.
- **Status:** **Selesai.**

### 🟡 **Fase 2: Server Lokal & Baca File** - *Deadline: 6 Minggu*
- **Backend:** Ubah script Python menjadi **FastAPI Server** yang berjalan di *background*.
- **Frontend:** Tambahkan fitur "Buka File .CBZ/.ZIP" dan "Mode Baca" (geser kiri/kanan).
- **Status:** **Dalam Pengerjaan.**

### 🔵 **Fase 3: Polish & Distribusi** - *Deadline: 8 Minggu*
- **Inpainting:** Implementasi LaMa untuk menghapus teks Jepang.
- **Packaging:** Buat file installer (`.exe`, `.dmg`, `.apk`) menggunakan **Flutter Build**.
- **Status:** **Rencana.**

---

## 6. 🚧 Batasan yang Tidak Boleh Dilewati (Non-Negotiables)

1.  **Privasi:** Aplikasi tidak boleh mengirim gambar komik mentah pengguna ke server eksternal (Cloud). Semua pemrosesan AI **harus lokal**.
2.  **Kompleksitas:** Jangan membuat fitur baru sebelum Fase 1 selesai.
3.  **Komunikasi:** Jika ada anggota yang *stuck* lebih dari 2 hari, **wajib** melapor di grup diskusi, jangan dipendam.

---

## 7. 🔗 Referensi & Sumber Belajar Tim

Jika ada anggota baru yang bergabung, arahkan mereka ke sini:
- **Dart/Flutter:** [Dokumentasi Resmi Flutter](https://docs.flutter.dev/)
- **Python FastAPI:** [Tutorial FastAPI](https://fastapi.tiangolo.com/)
- **MangaOCR:** [GitHub MangaOCR](https://github.com/kha-white/manga-ocr)
- **YOLOv8:** [Ultralytics Docs](https://docs.ultralytics.com/)

---
