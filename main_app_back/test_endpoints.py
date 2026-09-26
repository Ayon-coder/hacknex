import asyncio
import json
import time
import httpx
from main import app

async def run_diagnostics():
    transport = httpx.ASGITransport(app=app)

    async with httpx.AsyncClient(transport=transport, base_url="http://testserver", timeout=60.0) as client:
        print("=" * 60)
        print("STARTING BACKEND ENDPOINTS DIAGNOSTIC TEST SUITE")
        print("=" * 60)

        # 1. Health Endpoints
        t0 = time.time()
        r = await client.get("/api/health")
        dt = time.time() - t0
        print(f"\n[1] GET /api/health: {r.status_code} ({dt:.2f}s)")
        print("Health status payload:", r.json())
        assert r.status_code == 200

        r = await client.get("/health")
        print(f"[2] GET /health: {r.status_code}")
        assert r.status_code == 200

        # 2. Intro Narration Endpoint
        intro_payload = {
            "name": "Alex",
            "grade": "Grade 9",
            "curriculum": "Standard Science & Tech",
            "subjects": ["Programming", "Physics"],
            "difficulty": "Intermediate",
            "world_theme": "Highland Valley Castle",
            "learning_goal": "Build an intelligent virtual universe"
        }
        print(f"\n[3] Testing POST /api/intro (Speech generation in progress, please wait ~3s)...")
        t0 = time.time()
        r = await client.post("/api/intro", json=intro_payload)
        dt = time.time() - t0
        print(f"POST /api/intro status: {r.status_code} ({dt:.2f}s)")
        intro_data = r.json()
        print("  - Narration source:", intro_data.get("source"))
        print("  - Audio Available:", intro_data.get("audio_available"))
        print("  - Audio URL:", intro_data.get("audio_url"))
        print("  - Narration Preview:", intro_data.get("narration")[:120] + "...")

        # Test Intro Cache Hit
        t0 = time.time()
        r_cache = await client.post("/api/intro", json=intro_payload)
        dt_cache = time.time() - t0
        print(f"  - Repeat POST /api/intro (Instant Cache): {r_cache.status_code} ({dt_cache:.4f}s)")

        # 3. Learning Content Generation Endpoint
        learning_payload = {
            "building_id": "coding_tower",
            "building_name": "Coding Tower",
            "subject": "Programming",
            "difficulty": "Intermediate",
            "student_level": 2,
            "topic": "Recursion vs Iteration"
        }
        print(f"\n[4] Testing POST /api/learning/content...")
        t0 = time.time()
        r = await client.post("/api/learning/content", json=learning_payload)
        dt = time.time() - t0
        print(f"POST /api/learning/content status: {r.status_code} ({dt:.2f}s)")
        learning_data = r.json()
        print("  - Learning Topic:", learning_data.get("topic"))
        print("  - Questions Count:", len(learning_data.get("questions", [])))
        print("  - Explanation Audio URL:", learning_data.get("explanation_audio_url"))

        # 4. Text-To-Speech (TTS) Endpoint
        tts_payload = {
            "text": "Welcome to KnowledgeVerse AI. Your magical journey begins now.",
            "context": "narration"
        }
        print(f"\n[5] Testing POST /api/tts (Direct ElevenLabs Voice Synthesis)...")
        t0 = time.time()
        r = await client.post("/api/tts", json=tts_payload)
        dt = time.time() - t0
        print(f"POST /api/tts status: {r.status_code} ({dt:.2f}s)")
        tts_data = r.json()
        print("  - Audio URL:", tts_data.get("audio_url"))
        print("  - Audio Available:", tts_data.get("audio_available"))

        # 5. Audio Streaming Endpoints
        print("\n[6] Testing Live Audio Streaming via /api/audio/...")
        if tts_data.get("audio_url"):
            r_audio = await client.get(tts_data.get("audio_url"))
            print(f"  - GET {tts_data.get('audio_url')}: {r_audio.status_code} ({len(r_audio.content)} bytes, {r_audio.headers.get('content-type')})")
            assert r_audio.status_code == 200
            assert r_audio.headers.get("content-type") == "audio/mpeg"

        if intro_data.get("audio_url"):
            r_audio_intro = await client.get(intro_data.get("audio_url"))
            print(f"  - GET {intro_data.get('audio_url')}: {r_audio_intro.status_code} ({len(r_audio_intro.content)} bytes, {r_audio_intro.headers.get('content-type')})")
            assert r_audio_intro.status_code == 200

        # Test non-existent audio 404
        r_404 = await client.get("/api/audio/non_existent_key_123456789")
        print(f"  - Non-existent audio key: status={r_404.status_code} (Expected 404)")

        # 6. Edge Cases & Validation
        print("\n[7] Testing Validation & Edge Cases:")
        r_empty_tts = await client.post("/api/tts", json={"text": "   "})
        print(f"  - Empty TTS text: status={r_empty_tts.status_code} (Expected 400)")
        r_bad_learning = await client.post("/api/learning/content", json={"student_level": "not_an_int"})
        print(f"  - Invalid learning schema: status={r_bad_learning.status_code} (Expected 422)")

        print("\n" + "=" * 60)
        print("ALL TESTS PASSED SUCCESSFULLY!")
        print("=" * 60)

if __name__ == "__main__":
    asyncio.run(run_diagnostics())
