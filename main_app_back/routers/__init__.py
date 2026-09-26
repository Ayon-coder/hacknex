"""FastAPI route handlers package."""

from .health import router as health_router
from .intro import router as intro_router
from .learning import router as learning_router
from .audio import router as audio_router

__all__ = ["health_router", "intro_router", "learning_router", "audio_router"]
