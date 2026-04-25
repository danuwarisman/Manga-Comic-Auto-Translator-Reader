# Critical Fixes Applied (Sprint 1)

## Changes Made - April 22, 2026

### 1. ✅ Removed Empty `/server/` Folder
- **Issue**: Duplicate folder at root level, conflicting with `backend/server/`
- **Action**: Deleted confusing duplicate server structure from the project root
- **Impact**: Project structure is cleaner and backend entrypoint is now clearly under `backend/server/`

### 2. ✅ Created `backend/requirements.txt`
- **Issue**: Dependencies previously lived only in setup notes/scripts and were not managed in standard Python format
- **File**: `backend/requirements.txt`
- **Includes**: FastAPI, Uvicorn, MangaOCR, PyTorch-related packages, OpenCV, Pillow, comic/file handling dependencies
- **Impact**: Reproducible backend setup and easier installation for local development

### 3. ✅ Fixed Android App ID
- **Issue**: `com.example.frontend` was still a placeholder and not suitable for release packaging
- **File**: `frontend/android/app/build.gradle.kts`
- **Changed To**: `com.manga_translator.reader`
- **Impact**: Android package naming is now production-oriented

### 4. ✅ Updated Flutter Dependencies
- **Issue**: The initial Flutter app only had template dependencies and lacked packages needed for a real UI flow
- **File**: `frontend/pubspec.yaml`
- **Added / Updated**:
  - **Networking**: `dio`
  - **File Handling**: `file_picker`, `image_picker`, `path`
  - **Images / Utilities**: `image`, `cached_network_image`
  - **State Management**: `provider`
  - **Helpers**: `intl`, `uuid`, `shared_preferences`
- **Impact**: Frontend is ready to talk to the backend and manage OCR-oriented UI state

### 5. ✅ Implemented Flutter UI Foundation
- **Issue**: Project previously contained only the default Flutter counter template
- **Files Added / Updated**:
  - `frontend/lib/main.dart`
  - `frontend/lib/screens/home_screen.dart`
  - `frontend/lib/screens/results_screen.dart`
  - `frontend/lib/services/api_service.dart`
  - `frontend/lib/providers/translation_provider.dart`
  - `frontend/lib/models/translation_model.dart`
  - `frontend/lib/widgets/file_upload_widget.dart`

**Current UI capabilities**:
- ✅ File/image upload from Flutter
- ✅ Target language selection
- ✅ Upload/OCR loading state
- ✅ OCR result display in structured text blocks
- ✅ Error handling and reset flow
- ✅ Frontend contract aligned with the backend OCR MVP

### 6. ✅ Backend and Frontend API Contract Synchronized
- **Issue**: Frontend originally expected a translation job API (`/api/translate/status`, `/download`, async polling), while backend only exposed a simple OCR upload endpoint
- **Files Updated**:
  - `backend/server/main.py`
  - `frontend/lib/services/api_service.dart`
  - `frontend/lib/providers/translation_provider.dart`
  - `frontend/lib/models/translation_model.dart`
  - `frontend/lib/screens/home_screen.dart`
  - `frontend/lib/screens/results_screen.dart`
- **Changes Made**:
  - Added compatibility endpoint aliases for `/api/health` and `/api/translate/upload`
  - Standardized backend upload response so Flutter can parse it directly
  - Removed unsupported frontend polling/download assumptions for the current MVP
  - Clarified OCR-only behavior in the UI
- **Impact**: The app now reflects the real MVP scope instead of a not-yet-implemented translation pipeline

### 7. ✅ Documentation and Setup Updated
- **Files Updated**:
  - `README.md`
  - `setup.sh`
  - `.gitignore`
- **Changes Made**:
  - Replaced outdated `ScanBridge` naming with the actual project name
  - Updated setup instructions to use `requirements.txt`
  - Clarified current MVP scope: OCR upload and OCR result viewing
  - Removed stale documentation references to features not implemented yet
- **Impact**: GitHub-facing documentation is now aligned with the real codebase state

---

## Current MVP Scope

What works now:
1. Run local FastAPI backend
2. Upload an image from Flutter
3. Execute OCR with MangaOCR
4. Return OCR results in a frontend-friendly JSON format
5. Display OCR blocks in the Flutter UI

What does **not** exist yet:
1. Full translation pipeline
2. Async job status endpoint
3. Download translated output endpoint
4. Generated translated preview images
5. Balloon detection and inpainting pipeline

---

## Next Steps (Sprint 2)

1. Implement text balloon detection with YOLOv8
2. Add real translation integration
3. Add inpainting / text replacement
4. Add support for PDF / CBZ / ZIP pipeline
5. Return final translated assets and richer metadata

## Next Steps (Sprint 3)

1. Add automated tests for backend and frontend
2. Add `.env.example`
3. Add Docker support
4. Add CI/CD workflow
5. Improve logging and observability
6. Harden CORS and request validation

---

## How to Build & Test

### Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
uvicorn server.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

---

**Status**: ✅ **Sprint 1 fixes complete. Project is now synchronized around an OCR MVP, with translation pipeline work deferred to the next sprint.**
