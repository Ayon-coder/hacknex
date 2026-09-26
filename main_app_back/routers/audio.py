"""Audio streaming router endpoints."""

from fastapi import APIRouter, HTTPException, Response
from config import audio_cache, text_cache, inflight
from services.learning_service import synthesize_audio

router = APIRouter(tags=["Audio Stream"])


@router.get("/api/intro/{key}/audio")
@router.get("/api/audio/{key}")
@router.get("/api/learning/audio/{key}")
async def get_audio(key: str):
    if key in audio_cache:
        audio = audio_cache[key]
        return Response(
            content=audio,
            media_type="audio/mpeg",
            headers={
                "Content-Length": str(len(audio)),
                "Accept-Ranges": "bytes",
                "Cache-Control": "public, max-age=3600",
            },
        )

    # Check if synthesis task is inflight
    task = inflight.get(key)
    if task is not None:
        try:
            await task
        except Exception:
            pass

    if key in audio_cache:
        audio = audio_cache[key]
        return Response(
            content=audio,
            media_type="audio/mpeg",
            headers={
                "Content-Length": str(len(audio)),
                "Accept-Ranges": "bytes",
                "Cache-Control": "public, max-age=3600",
            },
        )

    # If text is cached but audio not yet synthesized, synthesize on demand
    if key in text_cache:
        try:
            audio = await synthesize_audio(key, text_cache[key])
            return Response(
                content=audio,
                media_type="audio/mpeg",
                headers={
                    "Content-Length": str(len(audio)),
                    "Accept-Ranges": "bytes",
                    "Cache-Control": "public, max-age=3600",
                },
            )
        except Exception:
            pass

    raise HTTPException(404, "Audio not found or generation failed")
