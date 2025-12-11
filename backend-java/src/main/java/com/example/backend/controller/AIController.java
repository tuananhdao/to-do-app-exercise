package com.example.backend.controller;

import com.example.backend.config.APIResponse;
import com.example.backend.dtos.GenerateTasksRequestDTO;
import com.example.backend.dtos.GenerateTasksResponseDTO;
import com.example.backend.dtos.VoiceToTextRequestDTO;
import com.example.backend.dtos.VoiceToTextResponseDTO;
import com.example.backend.exception.AIAPIException;
import com.example.backend.exception.AIConfigurationException;
import com.example.backend.exception.AIServiceException;
import com.example.backend.service.AIService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * REST controller for AI-related endpoints
 */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class AIController {

    private final AIService aiService;

    /**
     * Transcribes audio to text
     *
     * @param request Request containing base64-encoded audio and format
     * @return Transcription response with text
     */
    @PostMapping("/voice-to-text")
    public ResponseEntity<APIResponse<VoiceToTextResponseDTO>> voiceToText(
            @RequestBody VoiceToTextRequestDTO request) {
        
        // Validate request
        if (request.getAudioBase64() == null || request.getAudioBase64().isBlank()) {
            return ResponseEntity
                    .badRequest()
                    .body(APIResponse.error("Audio base64 data is required"));
        }

        try {
            VoiceToTextResponseDTO response = aiService.transcribeAudio(
                    request.getAudioBase64(),
                    request.getAudioFormat()
            );
            return ResponseEntity.ok(APIResponse.success(response));
        } catch (AIConfigurationException e) {
            return ResponseEntity
                    .status(500)
                    .body(APIResponse.error("Configuration error: " + e.getMessage()));
        } catch (AIAPIException e) {
            return ResponseEntity
                    .status(e.getStatusCode())
                    .body(APIResponse.error("API error: " + e.getMessage()));
        } catch (AIServiceException e) {
            return ResponseEntity
                    .internalServerError()
                    .body(APIResponse.error("Service error: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(APIResponse.error("Failed to transcribe audio: " + e.getMessage()));
        }
    }

    /**
     * Generates a task based on user prompt
     *
     * @param request Request containing prompt and optional maxTasks
     * @return Generated task response
     */
    @PostMapping("/generate-tasks")
    public ResponseEntity<APIResponse<GenerateTasksResponseDTO>> generateTasks(
            @RequestBody GenerateTasksRequestDTO request) {
        
        // Validate request
        if (request.getPrompt() == null || request.getPrompt().isBlank()) {
            return ResponseEntity
                    .badRequest()
                    .body(APIResponse.error("Prompt is required"));
        }

        try {
            GenerateTasksResponseDTO response = aiService.generateTasks(
                    request.getPrompt(),
                    request.getMaxTasks()
            );
            return ResponseEntity.ok(APIResponse.success(response));
        } catch (AIConfigurationException e) {
            return ResponseEntity
                    .status(500)
                    .body(APIResponse.error("Configuration error: " + e.getMessage()));
        } catch (AIAPIException e) {
            return ResponseEntity
                    .status(e.getStatusCode())
                    .body(APIResponse.error("API error: " + e.getMessage()));
        } catch (AIServiceException e) {
            return ResponseEntity
                    .internalServerError()
                    .body(APIResponse.error("Service error: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(APIResponse.error("Failed to generate tasks: " + e.getMessage()));
        }
    }
}

