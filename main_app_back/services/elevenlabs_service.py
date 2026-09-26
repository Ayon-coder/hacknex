"""ElevenLabs Text-To-Speech (TTS) service with full request/response auditing."""

import httpx
from config import ELEVENLABS_API_KEY, ELEVENLABS_URL, VOICE_ID, TTS_MODEL_ID, log


async def call_elevenlabs(text: str, model_id: str) -> bytes:
    masked_key = f"{ELEVENLABS_API_KEY[:6]}...{ELEVENLABS_API_KEY[-4:]}" if ELEVENLABS_API_KEY else "<EMPTY>"
    log.info("🔊 [ElevenLabs Audit]: API Key Loaded: %s (Length: %d)", masked_key, len(ELEVENLABS_API_KEY))
    log.info("🔊 [ElevenLabs Audit]: Voice ID: %s", VOICE_ID)
    log.info("🔊 [ElevenLabs Audit]: Target Model: %s", model_id)
    log.info("🔊 [ElevenLabs Audit]: Target URL: %s", ELEVENLABS_URL)

    payload = {
        "text": text,
        "model_id": model_id,
        "voice_settings": {
            "stability": 0.45,
            "similarity_boost": 0.75,
            "style": 0.35,
            "use_speaker_boost": True,
        },
    }
    headers = {
        "xi-api-key": ELEVENLABS_API_KEY,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
    }

    log.info(
        "🔊 [ElevenLabs Audit]: Sending HTTP POST Request to %s (Text len: %d)",
        ELEVENLABS_URL,
        len(text),
    )

    async with httpx.AsyncClient(timeout=20.0) as client:
        r = await client.post(
            ELEVENLABS_URL,
            json=payload,
            headers=headers,
            params={"output_format": "mp3_44100_128"},
        )
        log.info("🔊 [ElevenLabs Audit]: HTTP Response Status Code: %d", r.status_code)

        if r.status_code != 200:
            error_msg = f"ElevenLabs HTTP {r.status_code}: {r.text[:500]}"
            log.error("❌ [ElevenLabs Audit Error]: %s", error_msg)
            raise RuntimeError(error_msg)

        if not r.content:
            log.error("❌ [ElevenLabs Audit Error]: ElevenLabs returned empty audio bytes!")
            raise RuntimeError("ElevenLabs returned empty audio")

        log.info("✅ [ElevenLabs Audit Success]: Received %d audio bytes from ElevenLabs", len(r.content))
        return r.content


def tts_model_candidates() -> list[str]:
    candidates = [TTS_MODEL_ID, "eleven_v3", "eleven_multilingual_v2"]
    seen: set[str] = set()
    ordered: list[str] = []
    for model_id in candidates:
        model_id = model_id.strip()
        if model_id and model_id not in seen:
            seen.add(model_id)
            ordered.append(model_id)
    return ordered
