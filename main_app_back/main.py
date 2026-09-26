"""KnowledgeVerse AI Modular FastAPI Backend.

Proxies Gemini AI (narration & learning interaction generation) and ElevenLabs (speech synthesis)
so API keys never ship to the Flutter client.

Run with:
    uvicorn main:app --host 0.0.0.0 --port 8000
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import (
    health_router,
    intro_router,
    learning_router,
    audio_router,
)
from models import (
    OnboardingProfile,
    IntroResponse,
    LearningRequest,
    MCQuestion,
    LearningContentResponse,
    TTSRequest,
    TTSResponse,
)
from services import (
    call_gemini,
    call_elevenlabs,
    generate_intro,
    generate_learning_content,
    generate_tts,
)

app = FastAPI(
    title="KnowledgeVerse AI",
    description="Modular AI-Powered Learning & Voice Narration Backend",
    version="2.0.0",
)

# CORS Middleware setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

# Register modular APIRouter modules
app.include_router(health_router)
app.include_router(intro_router)
app.include_router(learning_router)
app.include_router(audio_router)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
