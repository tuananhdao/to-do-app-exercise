package com.example.backend.dtos;

import lombok.Data;

/**
 * DTO for voice-to-text transcription responses
 */
@Data
public class VoiceToTextResponseDTO {
    /**
     * Transcribed text from the audio
     */
    private String text;
}

