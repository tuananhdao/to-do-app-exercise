package com.example.backend.exception;

/**
 * Exception thrown when AI service configuration is invalid or missing
 */
public class AIConfigurationException extends AIServiceException {
    public AIConfigurationException(String message) {
        super(message);
    }

    public AIConfigurationException(String message, Throwable cause) {
        super(message, cause);
    }
}

