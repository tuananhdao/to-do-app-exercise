# AI Endpoints Setup

This document describes how to configure the AI endpoints that use Gemini 2.5 Flash Lite.

## Environment Variables

Create a `.env` file in the `backend-java` directory with the following content:

```env
OPENAI_API_KEY=your-api-key-here
OPENAI_API_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai
```

### Configuration Details

- **OPENAI_API_KEY**: Your Gemini API key for OpenAI-compatible API access
- **OPENAI_API_BASE_URL**: The base URL for the OpenAI-compatible API endpoint (defaults to `https://generativelanguage.googleapis.com/v1beta/openai` if not specified)

## Endpoints

### POST /api/v1/voice-to-text

Transcribes audio to text using Gemini 2.5 Flash Lite.

**Request Body:**
```json
{
  "audioBase64": "base64-encoded-audio-data",
  "audioFormat": "mp3"
}
```

**Response:**
```json
{
  "code": 1000,
  "message": "Success",
  "result": {
    "text": "Transcribed text here"
  }
}
```

### POST /api/v1/generate-tasks

Generates task suggestions based on a prompt using Gemini 2.5 Flash Lite.

**Request Body:**
```json
{
  "prompt": "Thêm danh sách đi chợ để nấu món bò sốt vang"
}
```

**Note:** The `maxTasks` parameter is optional and currently not used. The endpoint returns a single task with steps based on the prompt.

**Response:**
```json
{
  "code": 1000,
  "message": "Success",
  "result": {
    "id": 1,
    "title": "Task title",
    "completed": false,
    "steps": [
      {
        "id": 1,
        "items": "Step description",
        "completed": false
      }
    ]
  }
}
```

**Example Response:**
```json
{
  "code": 1000,
  "message": "Success",
  "result": {
    "id": 12,
    "title": "Thêm danh sách đi chợ để nấu món bò sốt vang",
    "completed": false,
    "steps": [
      { "id": 1, "items": "Thịt bò thăn 500g", "completed": false },
      { "id": 2, "items": "Rượu vang đỏ", "completed": false },
      { "id": 3, "items": "Cà rốt", "completed": false },
      { "id": 4, "items": "Khoai tây", "completed": false },
      { "id": 5, "items": "Sốt cà chua", "completed": false },
      { "id": 6, "items": "Hành tây", "completed": false },
      { "id": 7, "items": "Tỏi", "completed": false },
      { "id": 8, "items": "Gia vị: muối, tiêu, lá thơm", "completed": false }
    ]
  }
}
```

## Notes

- The `.env` file should be added to `.gitignore` to prevent committing sensitive API keys
- The API uses OpenAI-compatible format for compatibility with Gemini's OpenAI-compatible endpoint
- Make sure your API key has access to the `gemini-2.5-flash-lite` model

