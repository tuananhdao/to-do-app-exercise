package com.example.backend.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

/**
 * Utility class for parsing JSON from AI API responses
 */
@Slf4j
public final class JsonParserUtil {
    private JsonParserUtil() {
        // Utility class
    }

    /**
     * Extracts text content from AI API response (supports both Gemini and OpenAI formats)
     */
    public static String extractTextFromResponse(JsonNode jsonResponse, ObjectMapper objectMapper) {
        try {
            // Try Gemini format first
            if (jsonResponse.has("candidates") && jsonResponse.get("candidates").isArray()) {
                JsonNode candidates = jsonResponse.get("candidates");
                if (candidates.size() > 0) {
                    JsonNode candidate = candidates.get(0);
                    if (candidate.has("content") && candidate.get("content").has("parts")) {
                        JsonNode parts = candidate.get("content").get("parts");
                        if (parts.isArray() && parts.size() > 0) {
                            JsonNode part = parts.get(0);
                            if (part.has("text")) {
                                return part.get("text").asText();
                            }
                        }
                    }
                }
            }
            
            // Fallback: try OpenAI format
            if (jsonResponse.has("choices") && jsonResponse.get("choices").isArray()) {
                JsonNode choices = jsonResponse.get("choices");
                if (choices.size() > 0) {
                    JsonNode choice = choices.get(0);
                    if (choice.has("message") && choice.get("message").has("content")) {
                        return choice.get("message").get("content").asText();
                    }
                }
            }
            
            return jsonResponse.toString();
        } catch (Exception e) {
            log.error("Error extracting text from response", e);
            return jsonResponse.toString();
        }
    }

    /**
     * Extracts JSON object from text, removing markdown code blocks if present
     */
    public static String extractJsonFromText(String text) {
        if (text == null || text.trim().isEmpty()) {
            return null;
        }
        
        // Remove markdown code blocks
        String cleanedContent = text;
        if (text.contains("```")) {
            cleanedContent = text.replaceAll(com.example.backend.config.AIConstants.JSON_CODE_BLOCK_PATTERN, "")
                                 .replaceAll(com.example.backend.config.AIConstants.CODE_BLOCK_PATTERN, "")
                                 .trim();
        }
        
        // Try direct parsing if it starts with {
        String trimmed = cleanedContent.trim();
        if (trimmed.startsWith("{")) {
            String json = extractJsonObject(trimmed, 0);
            if (json != null) {
                return json;
            }
        }
        
        // Try to find JSON object in the text
        int startIndex = cleanedContent.indexOf('{');
        if (startIndex >= 0) {
            return extractJsonObject(cleanedContent, startIndex);
        }
        
        return null;
    }

    /**
     * Extracts a complete JSON object starting at the given index
     */
    private static String extractJsonObject(String text, int startIndex) {
        int braceCount = 0;
        int endIndex = -1;
        
        for (int i = startIndex; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == '{') {
                braceCount++;
            } else if (c == '}') {
                braceCount--;
                if (braceCount == 0) {
                    endIndex = i + 1;
                    break;
                }
            }
        }
        
        if (endIndex > startIndex) {
            return text.substring(startIndex, endIndex);
        }
        
        return null;
    }
}

