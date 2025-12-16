#!/bin/bash
# Demo script - Test Voice to AI Task feature

echo "================================================"
echo "🎤 DEMO: Voice to AI Task Feature"
echo "================================================"
echo ""

# Test 1: Voice to Text API
echo "📝 Test 1: Voice to Text API"
echo "Endpoint: POST http://localhost:8080/api/v1/voice-to-text"
echo ""
echo "Request example:"
cat << 'EOF'
{
  "audioBase64": "UklGRiQAAABXQVZFZm10IBAAAA...",
  "audioFormat": "wav"
}
EOF
echo ""
echo "Expected response:"
cat << 'EOF'
{
  "code": 1000,
  "message": "success",
  "result": {
    "text": "Tôi muốn lên kế hoạch tổ chức sinh nhật tuần tới"
  }
}
EOF
echo ""
echo "================================================"
echo ""

# Test 2: Generate Tasks API
echo "🤖 Test 2: Generate Tasks API"
echo "Endpoint: POST http://localhost:8080/api/v1/generate-tasks"
echo ""
echo "Request example:"
cat << 'EOF'
{
  "prompt": "Tôi muốn lên kế hoạch tổ chức sinh nhật tuần tới",
  "maxTasks": 1
}
EOF
echo ""
echo "Expected response:"
cat << 'EOF'
{
  "code": 1000,
  "message": "success",
  "result": {
    "id": 123,
    "title": "Lên kế hoạch tổ chức sinh nhật",
    "completed": false,
    "steps": [
      {
        "id": 456,
        "items": "Chọn địa điểm tổ chức",
        "completed": false
      },
      {
        "id": 457,
        "items": "Lập danh sách khách mời",
        "completed": false
      },
      {
        "id": 458,
        "items": "Đặt bánh sinh nhật",
        "completed": false
      },
      {
        "id": 459,
        "items": "Chuẩn bị quà tặng",
        "completed": false
      }
    ]
  }
}
EOF
echo ""
echo "================================================"
echo ""

# Test with curl (if backend is running)
echo "💡 Quick test with curl:"
echo ""
echo "# Test generate-tasks API:"
echo 'curl -X POST http://localhost:8080/api/v1/generate-tasks \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{"prompt":"Tôi muốn học lập trình Flutter","maxTasks":1}'"'"
echo ""
echo "================================================"
echo ""

# Flutter run commands
echo "🚀 Run Flutter app:"
echo ""
echo "# For Android Emulator:"
echo "flutter run -d android"
echo ""
echo "# For iOS Simulator:"
echo "flutter run -d ios"
echo ""
echo "# For Chrome (Web):"
echo "flutter run -d chrome"
echo ""
echo "================================================"
echo ""

# How to use
echo "📖 How to use the feature:"
echo ""
echo "1. Run Flutter app on device/emulator"
echo "2. Tap the small MIC button (blue-gray color)"
echo "3. On Mobile:"
echo "   - Allow microphone permission"
echo "   - Tap 'Bắt đầu ghi âm'"
echo "   - Speak clearly: 'Tôi muốn lên kế hoạch tổ chức sinh nhật'"
echo "   - Tap 'Dừng ghi âm'"
echo "   - Review the transcribed text"
echo "   - Tap 'Tạo Task'"
echo ""
echo "4. On Web:"
echo "   - Type in the text field"
echo "   - Tap 'Tạo Task'"
echo ""
echo "5. Wait for AI processing (2-5 seconds)"
echo "6. See the new todo appear in the list! 🎉"
echo ""
echo "================================================"

