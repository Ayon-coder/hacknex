"""AI Learning interaction system models."""

from typing import Optional
from pydantic import BaseModel, Field


class LearningRequest(BaseModel):
    building_id: str = Field(default="coding_tower")
    building_name: str = Field(default="Coding Tower")
    subject: str = Field(default="Programming")
    difficulty: str = Field(default="Intermediate")
    student_level: int = Field(default=1)
    topic: Optional[str] = None


class MCQuestion(BaseModel):
    id: int
    question: str
    options: list[str]
    correct_index: int
    explanation: str


class LearningContentResponse(BaseModel):
    building_id: str
    building_name: str
    subject: str
    topic: str
    explanation: str
    questions: list[MCQuestion]
    explanation_audio_url: Optional[str] = None
    audio_available: bool = False
    source: str  # "gemini" or "fallback"
    cache_key: str


class TTSRequest(BaseModel):
    text: str = Field(..., max_length=2000)
    context: Optional[str] = Field(default="narration")


class TTSResponse(BaseModel):
    audio_url: Optional[str] = None
    audio_available: bool = False
    cache_key: str
