# backend/server/main.py
from pathlib import Path
import shutil
import uuid

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from core.ocr import MangaOCRProcessor

app = FastAPI(title="ScanBridge API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = Path(__file__).resolve().parent.parent / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

@app.on_event("startup")
async def startup_event() -> None:
    app.state.ocr_processor = MangaOCRProcessor()

@app.get("/")
async def root() -> dict:
    return {"message": "ScanBridge Backend is running!"}

@app.get("/health")
async def health() -> dict:
    return {"status": "healthy"}


def get_ocr_processor() -> MangaOCRProcessor:
    processor = getattr(app.state, "ocr_processor", None)
    if processor is None:
        raise HTTPException(status_code=500, detail="OCR engine belum siap")
    return processor

@app.post("/upload")
async def upload_image(file: UploadFile = File(...)) -> JSONResponse:
    """Menerima upload gambar, menjalankan OCR, dan mengembalikan teks yang dikenali."""
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File harus berupa gambar")

    extension = Path(file.filename or "").suffix
    if not extension:
        extension = ".jpg"

    temp_path = UPLOAD_DIR / f"{uuid.uuid4()}{extension}"

    try:
        with temp_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        results = get_ocr_processor().extract_text(str(temp_path))
        return JSONResponse(status_code=200, content={
            "filename": file.filename,
            "texts": results,
        })

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Gagal memproses gambar: {exc}") from exc
    finally:
        if temp_path.exists():
            temp_path.unlink()
