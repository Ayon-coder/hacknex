# 🏰 KnowledgeVerse AI — Interactive Learning Academy

[![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.x%20%7C%20Flame-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI%20%7C%20Python-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Gemini AI](https://img.shields.io/badge/AI-Google%20Gemini%20API-4285F4?logo=google)](https://ai.google.dev)
[![ElevenLabs](https://img.shields.io/badge/Audio-ElevenLabs%20TTS-FF5722)](https://elevenlabs.io)

An immersive 2D RPG learning world built with **Flutter** and **FastAPI**, featuring **Google Gemini AI** for dynamic subject lesson generation and **ElevenLabs** for realistic voice narration.

---

## 🌟 Features

- 🧙‍♂️ **Character World Exploration**: Move your character through subject towers (Programming, Physics, Chemistry, Mathematics, etc.) built with the **Flame engine**.
- 🧠 **AI-Powered Building Interaction**: Interacting with any building generates:
  - A concise, 1-minute read topic explanation with real-world analogies and conceptual learning focus.
  - 4 multiple-choice questions tailored to the player's level.
- 🔊 **ElevenLabs Voice Narration**: Hear life-like voice narration for topic explanations, cinematic intro letters, and quiz questions.
- 🏆 **Focus XP & Upgrades**: Solve quizzes correctly to reward your subject building with Focus XP and unlock visual magic upgrades.
- ⚡ **Asynchronous Streaming Architecture**: Immediate AI text rendering (~1.5s) with background voice synthesis to eliminate UI blocking or timeouts.

---

## 📂 Project Structure

```
hexa_final/
├── main_app/                      # Flutter Frontend Application
│   ├── lib/
│   │   ├── game/                  # Flame Game Engine World, Player, & HUD
│   │   │   ├── ui/dialogs/        # Building Learning Panel & Lesson Launcher
│   │   ├── models/                # Dart Data Models (LearningContent, Quiz)
│   │   ├── screens/               # World, Profile, Onboarding, & Map Screens
│   │   ├── services/              # API, AudioNarrationPlayer, & Learning Services
│   │   └── main.dart              # Application Entry Point
│   └── pubspec.yaml
│
└── main_app_back/                 # Modular FastAPI Backend
    ├── models/                    # Pydantic Schemas (Learning, Intro, TTS)
    ├── services/                  # Gemini AI & ElevenLabs TTS Integration
    ├── routers/                   # API Route Endpoints (/api/health, /api/learning, /api/audio)
    ├── config.py                  # Environment & Centralized Cache State
    ├── main.py                    # FastAPI Entry Point
    └── requirements.txt
```

---

## ⚙️ Prerequisites & Environment Setup

### 1. Backend Configuration (`main_app_back/.env`)

Create a `.env` file in the `main_app_back/` folder:

```env
GEMINI_API_KEY=your_google_gemini_api_key
ELEVENLABS_API_KEY=your_elevenlabs_api_key
GEMINI_MODEL=gemini-3.5-flash-lite
ELEVENLABS_VOICE_ID=JBFqnCBsd6RMkjVDRZzb
ELEVENLABS_MODEL_ID=eleven_multilingual_v2
```

### 2. Frontend Configuration (`main_app/.env`)

Create a `.env` file in the `main_app/` folder:

```env
API_BASE_URL=http://127.0.0.1:8000
```

---

## 🚀 How to Run the Application

### Step 1: Launch the FastAPI Backend

```bash
# Navigate to backend directory
cd main_app_back

# Set up Python virtual environment & install dependencies
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Start the backend server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The backend server will run live at `http://127.0.0.1:8000`.

### Step 2: Launch the Flutter App

In a second terminal window:

```bash
# Navigate to Flutter app directory
cd main_app

# Install dependencies
flutter pub get

# Run on Linux desktop, macOS, Windows, or Chrome
flutter run
```

---

## 📡 API Endpoints Overview

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/health` | Returns backend health & API key configuration status. |
| `POST` | `/api/intro` | Generates personalized player welcome letter & voice narration. |
| `POST` | `/api/learning/content` | Requests Gemini AI topic explanation & 4 MCQs for a subject building. |
| `POST` | `/api/tts` | Synthesizes custom text into ElevenLabs MP3 voice narration on demand. |
| `GET` | `/api/audio/{key}` | Serves streamed audio (`audio/mpeg`) for voice narration. |

---

## 🛠️ Technology Stack

- **Frontend**: Flutter, Flame Game Engine, Provider, AudioPlayers, Google Fonts, HTTP.
- **Backend**: Python 3.14, FastAPI, Uvicorn, Asyncio, HTTPX, Pydantic, Python-Dotenv.
- **AI Integrations**: Google Gemini AI API (`gemini-3.5-flash-lite`), ElevenLabs Speech API (`eleven_multilingual_v2` / `eleven_v3`).

---

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).
hi 
