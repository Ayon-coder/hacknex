"""Onboarding profile and intro response data models."""

import hashlib
from typing import Optional
from pydantic import BaseModel, Field


class OnboardingProfile(BaseModel):
    name: str = Field(default="Explorer", max_length=60)
    grade: str = Field(default="", max_length=60)
    curriculum: str = Field(default="", max_length=60)
    subjects: list[str] = Field(default_factory=list)
    difficulty: str = Field(default="", max_length=40)
    world_theme: str = Field(default="", max_length=60)
    learning_goal: str = Field(default="", max_length=200)

    def cache_key(self) -> str:
        raw = "|".join(
            [
                self.name.strip().lower(),
                self.grade.strip().lower(),
                self.curriculum.strip().lower(),
                ",".join(sorted(s.strip().lower() for s in self.subjects)),
                self.difficulty.strip().lower(),
                self.world_theme.strip().lower(),
                self.learning_goal.strip().lower(),
            ]
        )
        return hashlib.sha256(raw.encode()).hexdigest()[:24]


class IntroResponse(BaseModel):
    narration: str
    audio_url: Optional[str]
    audio_available: bool
    source: str  # "gemini", "fallback", or "cache"
    cache_key: str
