import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_theme.dart';
import '../services/api_service.dart';

class VoiceInputDialog extends StatefulWidget {
  const VoiceInputDialog({super.key});

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  
  bool _isListening = false;
  bool _isProcessing = false;
  bool _useTextInput = kIsWeb; // Use text input for web, voice for mobile
  String? _transcribedText;
  String? _error;
  bool _speechAvailable = false;
  String _currentLocale = 'vi_VN';  // Vietnamese by default

  @override
  void initState() {
    super.initState();
    if (!_useTextInput) {
      _initSpeech();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    if (kIsWeb) return;
    
    try {
      bool available = await _speech.initialize(
        onError: (error) {
          setState(() {
            // Check if it's a timeout or emulator issue
            if (error.errorMsg.toLowerCase().contains('timeout') || 
                error.errorMsg.toLowerCase().contains('no match')) {
              _error = '⚠️ Speech recognition không hoạt động trên emulator. Vui lòng nhập text thay thế.';
              _useTextInput = true;
            } else {
              _error = 'Lỗi: ${error.errorMsg}';
            }
            _isListening = false;
          });
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
      );
      
      setState(() {
        _speechAvailable = available;
        if (!available) {
          _error = '⚠️ Speech recognition không khả dụng trên thiết bị này. Vui lòng nhập text thay thế.';
          _useTextInput = true;
        }
      });
    } catch (e) {
      setState(() {
        _error = '⚠️ Không thể khởi tạo speech recognition (có thể do emulator). Vui lòng nhập text thay thế.';
        _useTextInput = true;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      setState(() {
        _error = 'Nhận diện giọng nói không khả dụng';
      });
      return;
    }

    setState(() {
      _error = null;
      _transcribedText = null;
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcribedText = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
          }
        });
      },
      localeId: _currentLocale,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _generateTaskFromText() async {
    final text = _useTextInput ? _textController.text.trim() : _transcribedText;
    
    if (text == null || text.isEmpty) {
      setState(() {
        _error = _useTextInput
            ? 'Vui lòng nhập mô tả task'
            : 'Vui lòng nói mô tả task';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final todo = await _apiService.generateTasks(text);
      
      if (!mounted) return;
      
      Navigator.pop(context, todo);
    } catch (e) {
      setState(() {
        _error = 'Không thể tạo task: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Voice to AI Task',
                    style: AppTheme.h2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Content
            // Text input mode (for web)
            if (_useTextInput) ...[
              const Text(
                '📝 Mô tả task của bạn, AI sẽ tự động tạo todo với các bước chi tiết:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  hintText: 'VD: Tôi muốn lên kế hoạch tổ chức sinh nhật tuần tới',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 3,
                autofocus: true,
                enabled: !_isProcessing,
              ),
              const SizedBox(height: 16),
            ]
            // Voice input mode (for mobile)
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎤 Nhấn nút và nói mô tả task của bạn:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _useTextInput = true;
                        _error = null;
                      });
                    },
                    icon: const Icon(Icons.keyboard, size: 16),
                    label: const Text('Nhập text', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Recording button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _speechAvailable
                      ? (_isListening ? _stopListening : _startListening)
                      : null,
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    size: 32,
                  ),
                  label: Text(_isListening ? 'Dừng lại' : 'Bắt đầu nói'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    backgroundColor: _isListening ? Colors.red : const Color(0xFF3E5F8A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Transcribed text
              if (_transcribedText != null && _transcribedText!.isNotEmpty) ...[
                const Text(
                  '✅ Text đã chuyển đổi:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _transcribedText!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
            
            // Error message
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Processing indicator
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'AI đang tạo task...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Actions
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing || _isListening ? null : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isProcessing || _isListening ? null : _generateTaskFromText,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Tạo Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
