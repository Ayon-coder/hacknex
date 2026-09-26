"""KnowledgeVerse AI backend configuration and cache state."""

import asyncio
import logging
import os
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("knowledgeverse")

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "").strip()
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-flash-latest").strip()
VOICE_ID = os.getenv("ELEVENLABS_VOICE_ID", "JBFqnCBsd6RMkjVDRZzb").strip()
TTS_MODEL_ID = os.getenv("ELEVENLABS_MODEL_ID", "eleven_v3").strip()

GEMINI_URL = (
    f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"
)
ELEVENLABS_URL = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}"

# Caching state bounded to prevent unbounded memory growth
MAX_CACHE_ENTRIES = 128
narration_cache: dict[str, str] = {}
audio_cache: dict[str, bytes] = {}
text_cache: dict[str, str] = {}
inflight: dict[str, asyncio.Task] = {}


def evict_if_full(cache: dict) -> None:
    while len(cache) >= MAX_CACHE_ENTRIES:
        cache.pop(next(iter(cache)))
