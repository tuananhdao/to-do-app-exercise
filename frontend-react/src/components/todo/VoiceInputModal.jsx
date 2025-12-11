import { useState, useRef } from 'react';
import aiService from '../../services/aiService';

export default function VoiceInputModal({ isOpen, onClose, onTextGenerated }) {
  const [isRecording, setIsRecording] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState(null);
  const [recordingTime, setRecordingTime] = useState(0);
  
  const mediaRecorderRef = useRef(null);
  const chunksRef = useRef([]);
  const timerRef = useRef(null);

  const startRecording = async () => {
    try {
      setError(null);
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      
      // Check supported MIME types - prefer WAV, fallback to MP3 compatible formats
      let mimeType = 'audio/webm;codecs=opus'; // Default fallback
      let audioFormat = 'wav'; // Target format for API
      
      // Try to use WAV if supported
      if (MediaRecorder.isTypeSupported('audio/wav')) {
        mimeType = 'audio/wav';
        audioFormat = 'wav';
      } 
      // Try MP3 compatible formats
      else if (MediaRecorder.isTypeSupported('audio/mp4')) {
        mimeType = 'audio/mp4';
        audioFormat = 'mp3';
      }
      else if (MediaRecorder.isTypeSupported('audio/mpeg')) {
        mimeType = 'audio/mpeg';
        audioFormat = 'mp3';
      }
      
      const mediaRecorder = new MediaRecorder(stream, { mimeType });
      mediaRecorderRef.current = mediaRecorder;
      chunksRef.current = [];

      mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) {
          chunksRef.current.push(e.data);
        }
      };

      mediaRecorder.onstop = async () => {
        const audioBlob = new Blob(chunksRef.current, { type: mimeType });
        await processAudio(audioBlob, audioFormat);
        
        // Stop all tracks
        stream.getTracks().forEach(track => track.stop());
      };

      mediaRecorder.start();
      setIsRecording(true);
      setRecordingTime(0);

      // Start timer
      timerRef.current = setInterval(() => {
        setRecordingTime(prev => prev + 1);
      }, 1000);

    } catch (err) {
      setError('Không thể truy cập microphone. Vui lòng cho phép quyền truy cập!');
      console.error('Error accessing microphone:', err);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
      
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    }
  };

  const processAudio = async (audioBlob, audioFormat) => {
    setIsProcessing(true);
    setError(null);

    try {
      // Convert blob to base64
      const reader = new FileReader();
      reader.readAsDataURL(audioBlob);
      
      reader.onloadend = async () => {
        const base64Audio = reader.result.split(',')[1]; // Remove data:audio/xxx;base64, prefix
        
        try {
          const response = await aiService.voiceToText(base64Audio, audioFormat);
          
          if (response.text) {
            onTextGenerated(response.text);
            handleClose();
          } else {
            setError('Không nhận diện được giọng nói. Vui lòng thử lại!');
          }
        } catch (err) {
          setError(err.message || 'Có lỗi xảy ra khi xử lý âm thanh');
        } finally {
          setIsProcessing(false);
        }
      };
    } catch (err) {
      setError('Không thể xử lý file âm thanh');
      setIsProcessing(false);
    }
  };

  const handleClose = () => {
    if (isRecording) {
      stopRecording();
    }
    if (timerRef.current) {
      clearInterval(timerRef.current);
    }
    setRecordingTime(0);
    setError(null);
    onClose();
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-xl font-bold text-gray-900">Nhập bằng giọng nói</h3>
          <button
            onClick={handleClose}
            className="text-gray-400 hover:text-gray-600"
            disabled={isProcessing}
          >
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M18 6L6 18M6 6l12 12" />
            </svg>
          </button>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
            {error}
          </div>
        )}

        <div className="text-center py-8">
          {isProcessing ? (
            <div>
              <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-600 mx-auto mb-4"></div>
              <p className="text-gray-600">Đang xử lý...</p>
            </div>
          ) : (
            <div>
              <button
                onClick={isRecording ? stopRecording : startRecording}
                className={`mx-auto w-24 h-24 rounded-full flex items-center justify-center transition-all ${
                  isRecording 
                    ? 'bg-red-500 hover:bg-red-600 animate-pulse' 
                    : 'bg-blue-500 hover:bg-blue-600'
                }`}
              >
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
                  {isRecording ? (
                    <rect x="6" y="6" width="12" height="12" />
                  ) : (
                    <>
                      <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
                      <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
                      <line x1="12" y1="19" x2="12" y2="23"/>
                      <line x1="8" y1="23" x2="16" y2="23"/>
                    </>
                  )}
                </svg>
              </button>
              
              {isRecording && (
                <div className="mt-4">
                  <p className="text-2xl font-mono text-red-600">{formatTime(recordingTime)}</p>
                  <p className="text-sm text-gray-500 mt-2">Đang ghi âm...</p>
                </div>
              )}
              
              {!isRecording && (
                <p className="text-gray-600 mt-4">
                  Nhấn để bắt đầu ghi âm
                </p>
              )}
            </div>
          )}
        </div>

        <div className="mt-6 text-center text-sm text-gray-500">
          <p>💡 Mẹo: Nói rõ ràng và tránh tiếng ồn xung quanh</p>
        </div>
      </div>
    </div>
  );
}
