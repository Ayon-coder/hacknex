"""AI Learning interaction system router endpoints."""

from fastapi import APIRouter
from models import (
    LearningRequest,
    LearningContentResponse,
    TTSRequest,
    TTSResponse,
)
from services import generate_learning_content, generate_tts

router = APIRouter(tags=["AI Learning System"])


@router.post("/api/learning/content", response_model=LearningContentResponse)
async def get_learning_content(req: LearningRequest):
    return await generate_learning_content(req)


@router.post("/api/tts", response_model=TTSResponse)
async def tts_endpoint(req: TTSRequest):
    return await generate_tts(req)
