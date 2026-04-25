from datetime import datetime, timezone
from pathlib import Path
import shutil
import uuid

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from core.ocr import MangaOCRProcessor

app = FastAPI(
    title="Manga Comic Auto Translator Reader API",
    version="0.1.0",
)

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
    try:
        app.state.ocr_processor = MangaOCRProcessor()
        app.state.ocr_error = None
    except Exception as exc:
        app.state.ocr_processor = None
        app.state.ocr_error = str(exc)


@app.get("/")
async def root() -> dict:
    return {
        "message": "Manga Comic Auto Translator Reader backend is running!",
    }


@app.get("/health")
@app.get("/api/health")
async def health() -> dict:
    return {
        "status": "healthy",
        "ocr_ready": getattr(app.state, "ocr_processor", None) is not None,
        "ocr_error": getattr(app.state, "ocr_error", None),
    }


def get_ocr_processor() -> MangaOCRProcessor:
    processor = getattr(app.state, "ocr_processor", None)
    if processor is None:
        error_message = getattr(app.state, "ocr_error", None) or "OCR engine belum siap"
        raise HTTPException(status_code=503, detail=error_message)
    return processor


def build_translation_response(
    filename: str | None,
    target_language: str,
    texts: list[dict],
) -> dict:
    created_at = datetime.now(timezone.utc).isoformat()
    text_blocks = [
        {
            "original_text": item.get("text", ""),
            "translated_text": "",
            "confidence": float(item.get("confidence") or 0.0),
        }
        for item in texts
    ]

    return {
        "file_name": filename or "uploaded-image",
        "status": "completed",
        "target_language": target_language,
        "created_at": created_at,
        "pages": [
            {
                "page_number": 1,
                "original_image_url": "",
                "translated_image_url": "",
                "text_blocks": text_blocks,
                "status": "completed",
            }
        ],
        "texts": texts,
    }


@app.post("/upload")
@app.post("/api/translate/upload")
async def upload_image(
    file: UploadFile = File(...),
    target_language: str = Form("english"),
) -> JSONResponse:
    """Menerima upload gambar, menjalankan OCR, dan mengembalikan hasil OCR dalam format frontend MVP."""
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File harus berupa gambar")

    extension = Path(file.filename or "").suffix or ".jpg"
    temp_path = UPLOAD_DIR / f"{uuid.uuid4()}{extension}"

    try:
        with temp_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        results = get_ocr_processor().extract_text(str(temp_path))
        response_payload = build_translation_response(
            filename=file.filename,
            target_language=target_language,
            texts=results,
        )
        return JSONResponse(status_code=200, content=response_payload)

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Gagal memproses gambar: {exc}",
        ) from exc
    finally:
        if temp_path.exists():
            temp_path.unlink()
