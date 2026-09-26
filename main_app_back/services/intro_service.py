"""Intro cinematic narration service."""

import asyncio
from config import narration_cache, audio_cache, inflight, evict_if_full, log
from models.onboarding import OnboardingProfile, IntroResponse
from services.gemini_service import call_gemini
from services.elevenlabs_service import call_elevenlabs, tts_model_candidates


def subject_phrase(subjects: list[str]) -> str:
    clean = [s.strip() for s in subjects if s.strip()]
    if not clean:
        return "many wonders"
    if len(clean) == 1:
        return clean[0]
    if len(clean) == 2:
        return f"{clean[0]} and {clean[1]}"
    return ", ".join(clean[:-1]) + f", and {clean[-1]}"


def build_intro_prompt(p: OnboardingProfile) -> str:
    goal = p.learning_goal.strip() or "to master their chosen subjects and earn their place among the great witches and wizards"
    return f"""You are the narrator of KnowledgeVerse, a wizarding school where students build their own castle of knowledge by learning.

Write a cinematic welcome narration for a new student, spoken aloud as the camera sweeps across a black lake toward a castle rising in the moonlight.

Student details:
- Name: {p.name or "Explorer"}
- Year / Grade: {p.grade or "not specified"}
- Curriculum: {p.curriculum or "not specified"}
- Chosen subjects: {subject_phrase(p.subjects)}
- Difficulty: {p.difficulty or "balanced"}
- Castle grounds theme: {p.world_theme or "a green highland valley beneath a starlit sky"}
- Learning goal: {goal}

Rules:
- Address the student directly by name in the first sentence, as though their acceptance letter has just arrived.
- Between 80 and 150 words.
- Reference their actual chosen subjects naturally, reimagined as classes in a school of magic — but keep the real subject names recognisable.
- Evoke the castle grounds theme in the imagery you use.
- Draw on wizarding-school atmosphere: owls, candlelight, moving staircases, the Great Hall, enchanted portraits, a sorting ceremony, the forbidden forest.
- Warm, inspiring, cinematic. Never robotic, never corporate.
- Connect learning to building: every lesson raises another tower, corridor, library or laboratory of their own castle.
- End on a line that launches the adventure.
- Output ONLY the narration text. No headings, no markdown, no stage directions, no quotation marks."""


def fallback_intro_narration(p: OnboardingProfile) -> str:
    name = p.name.strip() or "Explorer"
    subjects = subject_phrase(p.subjects)
    theme = p.world_theme.strip() or "a green highland valley"
    return (
        f"{name} — the owls have been waiting for you. "
        f"Tonight the lanterns are lit, and a place has been set aside for a student of {subjects}. "
        f"Across the water lies {theme}, and above it a castle that is not yet finished, "
        "because it is yours to raise. Every lesson you master lays another stone: "
        "corridors and staircases, libraries and laboratories, towers with candles burning in every window. "
        "The staircases will move, the portraits will argue, and the forest beyond will keep its secrets. "
        "Your knowledge will become your castle. Step inside — your first lesson is about to begin."
    )


async def generate_intro(profile: OnboardingProfile, key: str) -> IntroResponse:
    source = "gemini"
    try:
        narration = await call_gemini(build_intro_prompt(profile))
    except Exception as exc:
        log.warning("Gemini failed, using fallback narration: %s", exc)
        narration = fallback_intro_narration(profile)
        source = "fallback"

    evict_if_full(narration_cache)
    narration_cache[key] = narration

    audio_available = False
    try:
        last_error: Exception | None = None
        for model_id in tts_model_candidates():
            try:
                audio = await call_elevenlabs(narration, model_id)
                evict_if_full(audio_cache)
                audio_cache[key] = audio
                audio_available = True
                log.info("Generated %d bytes of audio for %s with %s", len(audio), key, model_id)
                break
            except Exception as exc:
                last_error = exc
                log.warning("ElevenLabs model %s failed for %s: %s", model_id, key, exc)
        if not audio_available and last_error is not None:
            raise last_error
    except Exception as exc:
        log.warning("ElevenLabs failed, client will fall back to subtitles: %s", exc)

    return IntroResponse(
        narration=narration,
        audio_url=f"/api/intro/{key}/audio" if audio_available else None,
        audio_available=audio_available,
        source=source,
        cache_key=key,
    )
