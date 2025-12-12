package com.example.backend.config;

/**
 * Constants for AI service configuration
 */
public final class AIConstants {
    private AIConstants() {
        // Utility class
    }

    public static final String MODEL_NAME = "gemini-2.5-flash-lite";
    public static final String CHAT_COMPLETIONS_ENDPOINT = "chat/completions";
    
    // Audio transcription constants
    public static final String DEFAULT_AUDIO_FORMAT = "mp3";
    public static final String AUDIO_CONTENT_TYPE = "input_audio";
    public static final String TEXT_CONTENT_TYPE = "text";
    
    // Task generation constants
    public static final double DEFAULT_TEMPERATURE = 0.7;
    public static final int DEFAULT_MAX_TOKENS = 2000;
    public static final int DEFAULT_MAX_TASKS = 10;
    
    // JSON parsing constants
    public static final String JSON_CODE_BLOCK_PATTERN = "(?s)```json\\s*";
    public static final String CODE_BLOCK_PATTERN = "(?s)```\\s*";
    public static final int MAX_TITLE_LENGTH = 200;
    public static final int FALLBACK_TITLE_LENGTH = 100;
}