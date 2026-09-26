"""Onboarding cinematic intro router endpoints."""

import asyncio
from fastapi import APIRouter, HTTPException
from config import GEMINI_API_KEY, ELEVENLABS_API_KEY, narration_cache, audio_cache, inflight, log
from models import OnboardingProfile, IntroResponse
from services import generate_intro

router = APIRouter(tags=["Intro Narration"])


@router.post("/api/intro", response_model=IntroResponse)
async def create_intro(profile: OnboardingProfile):
    if not GEMINI_API_KEY and not ELEVENLABS_API_KEY:
        raise HTTPException(500, "No API keys configured on the server")

    key = profile.cache_key()

    if key in narration_cache:
        log.info("Cache hit for %s", key)
        return IntroResponse(
            narration=narration_cache[key],
            audio_url=f"/api/intro/{key}/audio" if key in audio_cache else None,
            audio_available=key in audio_cache,
            source="cache",
            cache_key=key,
        )

    task = inflight.get(key)
    if task is None:
        task = asyncio.create_task(generate_intro(profile, key))
        inflight[key] = task
        try:
            return await task
        finally:
            inflight.pop(key, None)
    return await task
