# backend/core/ocr.py
from pathlib import Path
from typing import Any, Dict, List

import manga_ocr
from PIL import Image

class MangaOCRProcessor:
    def __init__(self) -> None:
        print("🔄 Memuat MangaOCR... (sekitar 200-300 MB, hanya sekali)")
        self.ocr = manga_ocr.MangaOcr()
        print("✅ MangaOCR siap digunakan.")

    def extract_text(self, image_path: str) -> List[Dict[str, Any]]:
        """Mengekstrak teks dari gambar menggunakan MangaOCR."""
        image_file = Path(image_path)
        if not image_file.exists():
            raise FileNotFoundError(f"File gambar tidak ditemukan: {image_file}")

        with Image.open(image_file) as img:
            text = self.ocr(img)

        return [{
            "text": text.strip(),
            "bbox": None,
            "confidence": None,
        }]
