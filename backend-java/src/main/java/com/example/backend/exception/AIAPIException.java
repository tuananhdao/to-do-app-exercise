package com.example.backend.exception;

/**
 * Exception thrown when AI API call fails
 */
public class AIAPIException extends AIServiceException {
    private final int statusCode;

    public AIAPIException(String message, int statusCode) {
        super(message);
        this.statusCode = statusCode;
    }

    public AIAPIException(String message, int statusCode, Throwable cause) {
        super(message, cause);
        this.statusCode = statusCode;
    }

    public int getStatusCode() {
        return statusCode;
    }
}

