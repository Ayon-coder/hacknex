"""Gemini AI API proxy service."""

import asyncio
import re
import httpx
from config import GEMINI_API_KEY, GEMINI_URL, log


def clean_narration(text: str) -> str:
    text = re.sub(r"^```[a-z]*\s*|\s*```$", "", text.strip())
    text = re.sub(r"[*_#]", "", text)
    text = re.sub(r"\s+\n", "\n", text)
    return text.strip().strip('"')


async def call_gemini(prompt: str) -> str:
    """Ask Gemini for text/JSON output. Retries transient failures with backoff."""
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 1.15,
            "topP": 0.95,
            "maxOutputTokens": 8192,
        },
    }
    headers = {"x-goog-api-key": GEMINI_API_KEY, "Content-Type": "application/json"}
    last_error = "unknown error"

    async with httpx.AsyncClient(timeout=12.0) as client:
        for attempt in range(3):
            try:
                r = await client.post(GEMINI_URL, json=payload, headers=headers)
                if r.status_code == 200:
                    data = r.json()
                    candidates = data.get("candidates") or []
                    if candidates:
                        parts = candidates[0].get("content", {}).get("parts") or []
                        text = "".join(
                            p.get("text", "") for p in parts if not p.get("thought")
                        )
                        if text.strip():
                            return clean_narration(text)
                    last_error = "empty candidate"
                elif r.status_code in (429, 500, 502, 503, 504):
                    last_error = f"HTTP {r.status_code}"
                else:
                    raise RuntimeError(f"Gemini HTTP {r.status_code}: {r.text[:200]}")
            except httpx.RequestError as exc:
                last_error = f"network: {exc}"

            if attempt < 2:
                await asyncio.sleep(1.5 * (attempt + 1))

    raise RuntimeError(f"Gemini unavailable after 3 attempts ({last_error})")
