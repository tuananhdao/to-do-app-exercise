package com.example.backend.dtos;

import lombok.Data;

/**
 * DTO for voice-to-text transcription requests
 */
@Data
public class VoiceToTextRequestDTO {
    /**
     * Base64-encoded audio data (required)
     */
    private String audioBase64;
    
    /**
     * Audio format (e.g., "mp3", "wav", "m4a")
     * Defaults to "mp3" if not provided
     */
    private String audioFormat;
}

