import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/api_service.dart';

// For non-web platforms
import 'package:flutter_sound/flutter_sound.dart' if (dart.library.html) '';
import 'package:permission_handler/permission_handler.dart' if (dart.library.html) '';
import 'package:path_provider/path_provider.dart' if (dart.library.html) '';

class VoiceInputDialog extends StatefulWidget {
  const VoiceInputDialog({super.key});

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  FlutterSoundRecorder? _recorder;
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _useTextInput = kIsWeb; // Use text input for web, voice for mobile
  String? _transcribedText;
  String? _error;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    if (!_useTextInput) {
      _initRecorder();
    }
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _textController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    if (kIsWeb) return;
    
    try {
      _recorder = FlutterSoundRecorder();
      
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        setState(() {
          _error = 'Microphone permission is required';
        });
        return;
      }

      await _recorder!.openRecorder();
      setState(() {
        _isRecorderInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize recorder: $e';
        _useTextInput = true; // Fallback to text input
      });
    }
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized || _recorder == null) {
      setState(() {
        _error = 'Recorder not initialized';
      });
      return;
    }

    try {
      setState(() {
        _error = null;
        _transcribedText = null;
      });

      // Get temporary directory for recording
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/voice_recording.wav';
      _recordingPath = path;

      await _recorder!.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder?.stopRecorder();
      
      setState(() {
        _isRecording = false;
      });

      if (_recordingPath != null) {
        await _transcribeAudio(_recordingPath!);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to stop recording: $e';
        _isRecording = false;
      });
    }
  }

  Future<void> _transcribeAudio(String path) async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Read audio file
      final file = File(path);
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);
      
      // Call voice-to-text API
      final text = await _apiService.voiceToText(base64Audio, 'wav');
      
      setState(() {
        _transcribedText = text;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Transcription failed: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _generateTaskFromText() async {
    final text = _useTextInput ? _textController.text.trim() : _transcribedText;
    
    if (text == null || text.isEmpty) {
      setState(() {
        _error = 'Please ${_useTextInput ? 'enter' : 'record'} a task description';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Call generate-tasks API (backend will auto-save to database)
      final todo = await _apiService.generateTasks(text);
      
      if (mounted) {
        Navigator.pop(context, todo);
      }
    } catch (e) {
      setState(() {
        _error = 'Task generation failed: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_useTextInput ? Icons.smart_toy : Icons.mic, 
               color: const Color(0xFF3E5F8A)),
          const SizedBox(width: 8),
          Text(_useTextInput ? 'AI Task Generator' : 'Voice Input'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text input mode (for web)
            if (_useTextInput) ...[
              const Text(
                'Describe your task and AI will help you break it down:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  hintText: 'e.g., Plan a birthday party for next week',
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
              // Recording button
              if (!_isRecording && _transcribedText == null)
                Column(
                  children: [
                    const Text(
                      'Press the button to start recording',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isProcessing || !_isRecorderInitialized 
                          ? null 
                          : _startRecording,
                      icon: const Icon(Icons.mic, size: 32),
                      label: const Text('Start Recording'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        backgroundColor: const Color(0xFF3E5F8A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              
              // Recording indicator
              if (_isRecording)
                Column(
                  children: [
                    const Icon(
                      Icons.mic,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Recording...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Speak clearly about your task',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              
              // Transcribed text
              if (_transcribedText != null && !_isProcessing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Transcribed Text:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        _transcribedText!,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ],
            
            // Processing indicator
            if (_isProcessing)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_transcribedText == null && !_useTextInput
                        ? 'Transcribing audio...'
                        : 'AI is generating your task...'),
                  ],
                ),
              ),
            
            // Error message
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing || _isRecording ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!_useTextInput && _transcribedText != null && !_isProcessing)
          TextButton(
            onPressed: () {
              setState(() {
                _transcribedText = null;
                _error = null;
              });
            },
            child: const Text('Re-record'),
          ),
        if ((_useTextInput || _transcribedText != null) && !_isProcessing)
          FilledButton.icon(
            onPressed: _generateTaskFromText,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Task'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3E5F8A),
            ),
          ),
      ],
    );
  }
}
