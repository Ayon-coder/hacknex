"""Health check router endpoints."""

from fastapi import APIRouter
from config import GEMINI_API_KEY, ELEVENLABS_API_KEY, GEMINI_MODEL, VOICE_ID, narration_cache

router = APIRouter(tags=["Health"])


@router.get("/api/health")
@router.get("/health")
async def health():
    return {
        "status": "ok",
        "gemini_key_configured": bool(GEMINI_API_KEY),
        "elevenlabs_key_configured": bool(ELEVENLABS_API_KEY),
        "gemini_model": GEMINI_MODEL,
        "voice_id": VOICE_ID,
        "cached_intros": len(narration_cache),
    }
