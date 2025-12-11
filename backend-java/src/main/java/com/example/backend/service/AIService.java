package com.example.backend.service;

import com.example.backend.config.AIConstants;
import com.example.backend.dtos.GenerateTasksResponseDTO;
import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.dtos.TodoStepRequestDTO;
import com.example.backend.dtos.VoiceToTextResponseDTO;
import com.example.backend.exception.AIAPIException;
import com.example.backend.exception.AIConfigurationException;
import com.example.backend.exception.AIServiceException;
import com.example.backend.model.Todo;
import com.example.backend.model.TodoStep;
import com.example.backend.util.JsonParserUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service for AI-related operations including voice-to-text transcription
 * and task generation using Gemini API
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AIService {

    private final WebClient webClient;
    private final String openAiApiKey;
    private final String openAiApiBaseUrl;
    private final TodoService todoService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Transcribes audio to text using AI API
     *
     * @param audioBase64 Base64-encoded audio data
     * @param audioFormat Audio format (e.g., "mp3", "wav", "m4a")
     * @return Transcription response with text
     * @throws AIConfigurationException if API configuration is invalid
     * @throws AIAPIException if API call fails
     * @throws AIServiceException for other service errors
     */
    public VoiceToTextResponseDTO transcribeAudio(String audioBase64, String audioFormat) {
        try {
            validateConfiguration();
            
            Map<String, Object> requestBody = buildAudioTranscriptionRequest(audioBase64, audioFormat);
            String endpoint = buildEndpoint(AIConstants.CHAT_COMPLETIONS_ENDPOINT);
            
            log.debug("Calling voice-to-text endpoint: {}", endpoint);
            
            String response = callAIAPI(endpoint, requestBody);
            String transcribedText = extractTextFromResponse(response);
            
            VoiceToTextResponseDTO responseDTO = new VoiceToTextResponseDTO();
            responseDTO.setText(transcribedText);
            return responseDTO;

        } catch (AIServiceException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error transcribing audio", e);
            throw new AIServiceException("Failed to transcribe audio: " + e.getMessage(), e);
        }
    }

    /**
     * Generates a task based on user prompt using AI API and automatically saves it to database
     *
     * @param prompt User prompt describing the task
     * @param maxTasks Maximum number of tasks to generate (currently unused, generates single task)
     * @return Generated task response with database ID
     * @throws AIConfigurationException if API configuration is invalid
     * @throws AIAPIException if API call fails
     * @throws AIServiceException for other service errors
     */
    public GenerateTasksResponseDTO generateTasks(String prompt, Integer maxTasks) {
        try {
            validateConfiguration();
            
            Map<String, Object> requestBody = buildTaskGenerationRequest(prompt);
            String endpoint = buildEndpoint(AIConstants.CHAT_COMPLETIONS_ENDPOINT);
            
            log.debug("Calling generate-tasks endpoint: {}", endpoint);
            
            String response = callAIAPI(endpoint, requestBody);
            GenerateTasksResponseDTO generatedTask = parseTaskFromResponse(response, prompt);
            
            log.info("Parsed task - Title: {}, Steps count: {}", 
                    generatedTask.getTitle(), 
                    generatedTask.getSteps() != null ? generatedTask.getSteps().size() : 0);
            
            // Automatically save to database
            Todo savedTodo = saveTaskToDatabase(generatedTask);
            
            // Convert saved Todo back to GenerateTasksResponseDTO with real database IDs
            GenerateTasksResponseDTO savedTaskResponse = convertToGenerateTasksResponseDTO(savedTodo);
            
            log.info("Task saved to database with ID: {}", savedTodo.getId());
            
            return savedTaskResponse;

        } catch (AIServiceException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error generating tasks", e);
            throw new AIServiceException("Failed to generate tasks: " + e.getMessage(), e);
        }
    }

    /**
     * Validates that required configuration is present
     */
    private void validateConfiguration() {
        if (openAiApiKey == null || openAiApiKey.isBlank()) {
            throw new AIConfigurationException("OPENAI_API_KEY is not configured");
        }
        if (openAiApiBaseUrl == null || openAiApiBaseUrl.isBlank()) {
            throw new AIConfigurationException("OPENAI_API_BASE_URL is not configured");
        }
    }

    /**
     * Builds the request body for audio transcription
     */
    private Map<String, Object> buildAudioTranscriptionRequest(String audioBase64, String audioFormat) {
        String format = (audioFormat != null && !audioFormat.isBlank()) 
                ? audioFormat 
                : AIConstants.DEFAULT_AUDIO_FORMAT;
        
        return Map.of(
                "model", AIConstants.MODEL_NAME,
                "messages", List.of(
                        Map.of(
                                "role", "user",
                                "content", List.of(
                                        Map.of(
                                                "type", AIConstants.AUDIO_CONTENT_TYPE,
                                                "input_audio", Map.of(
                                                        "data", audioBase64,
                                                        "format", format
                                                )
                                        ),
                                        Map.of(
                                                "type", AIConstants.TEXT_CONTENT_TYPE,
                                                "text", "Transcribe this audio to text."
                                        )
                                )
                        )
                )
        );
    }

    /**
     * Builds the request body for task generation
     */
    private Map<String, Object> buildTaskGenerationRequest(String prompt) {
        String systemPrompt = buildTaskGenerationSystemPrompt();
        
        return Map.of(
                "model", AIConstants.MODEL_NAME,
                "messages", List.of(
                        Map.of("role", "system", "content", systemPrompt),
                        Map.of("role", "user", "content", prompt)
                ),
                "temperature", AIConstants.DEFAULT_TEMPERATURE,
                "max_tokens", AIConstants.DEFAULT_MAX_TOKENS
        );
    }

    /**
     * Builds the system prompt for task generation
     */
    private String buildTaskGenerationSystemPrompt() {
        return "You are a helpful task management assistant. Generate a single task based on the user's request. " +
                "IMPORTANT: Return ONLY valid JSON, no additional text, explanation, or markdown formatting. " +
                "The JSON must have the following EXACT structure: " +
                "{\"id\": 1, \"title\": \"Task title\", \"completed\": false, \"steps\": [{\"id\": 1, \"items\": \"Item description\", \"completed\": false}, {\"id\": 2, \"items\": \"Another item\", \"completed\": false}]}. " +
                "Required fields: " +
                "- id: number (use 1 for the task id) " +
                "- title: string (descriptive title based on user's request) " +
                "- completed: boolean (always false) " +
                "- steps: array of objects, each with: " +
                "  * id: number (starting from 1, incrementing) " +
                "  * items: string (specific and detailed item/step description) " +
                "  * completed: boolean (always false) " +
                "If the user asks for a shopping list or items list, generate detailed steps with all the items needed. " +
                "Generate comprehensive, actionable steps for the task. " +
                "Return ONLY the JSON object, nothing else - no markdown code blocks, no explanations.";
    }

    /**
     * Builds the full endpoint URL
     */
    private String buildEndpoint(String path) {
        if (openAiApiBaseUrl.endsWith("/")) {
            return openAiApiBaseUrl + path;
        }
        return openAiApiBaseUrl + "/" + path;
    }

    /**
     * Makes the API call to the AI service
     */
    private String callAIAPI(String endpoint, Map<String, Object> requestBody) {
        try {
            String response = webClient.post()
                    .uri(endpoint)
                    .header("Authorization", "Bearer " + openAiApiKey)
                    .header("Content-Type", "application/json")
                    .bodyValue(requestBody)
                    .retrieve()
                    .onStatus(status -> status.is4xxClientError() || status.is5xxServerError(),
                            clientResponse -> {
                                log.error("API error: {}", clientResponse.statusCode());
                                return clientResponse.bodyToMono(String.class)
                                        .flatMap(errorBody -> {
                                            log.error("Error response body: {}", errorBody);
                                            return Mono.error(new AIAPIException(
                                                    "API error: " + clientResponse.statusCode() + " - " + errorBody,
                                                    clientResponse.statusCode().value()
                                            ));
                                        });
                            })
                    .bodyToMono(String.class)
                    .block();

            if (response == null || response.isBlank()) {
                throw new AIAPIException("Empty response from API", 500);
            }

            return response;
        } catch (AIAPIException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error calling AI API", e);
            throw new AIAPIException("Failed to call AI API: " + e.getMessage(), 500, e);
        }
    }

    /**
     * Extracts text from API response
     */
    private String extractTextFromResponse(String response) {
        try {
            JsonNode jsonResponse = objectMapper.readTree(response);
            return JsonParserUtil.extractTextFromResponse(jsonResponse, objectMapper);
        } catch (Exception e) {
            log.error("Error parsing response", e);
            throw new AIServiceException("Failed to parse API response: " + e.getMessage(), e);
        }
    }

    /**
     * Parses task from API response
     */
    private GenerateTasksResponseDTO parseTaskFromResponse(String response, String originalPrompt) {
        GenerateTasksResponseDTO task = new GenerateTasksResponseDTO();
        
        try {
            JsonNode jsonResponse = objectMapper.readTree(response);
            log.debug("Raw API response structure: {}", jsonResponse.toPrettyString());
            
            String textContent = JsonParserUtil.extractTextFromResponse(jsonResponse, objectMapper);
            log.debug("Extracted text content from AI response: {}", textContent);
            
            JsonNode taskNode = extractTaskNode(textContent);
            
            if (taskNode != null) {
                populateTaskFromNode(task, taskNode);
            } else {
                createFallbackTask(task, textContent, originalPrompt);
            }
        } catch (Exception e) {
            log.error("Error parsing task from response", e);
            createErrorTask(task);
        }
        
        return task;
    }

    /**
     * Extracts task node from text content
     */
    private JsonNode extractTaskNode(String textContent) {
        String jsonString = JsonParserUtil.extractJsonFromText(textContent);
        
        if (jsonString == null) {
            log.warn("Could not extract JSON from text content: {}", textContent);
            return null;
        }
        
        try {
            JsonNode parsed = objectMapper.readTree(jsonString);
            
            // Check if it's a single task object
            if (parsed.has("id") || parsed.has("title")) {
                log.debug("Successfully parsed task from JSON: {}", parsed);
                return parsed;
            }
            
            // Check if it's wrapped in a tasks array
            if (parsed.has("tasks") && parsed.get("tasks").isArray() && parsed.get("tasks").size() > 0) {
                JsonNode taskNode = parsed.get("tasks").get(0);
                log.debug("Successfully parsed task from tasks array: {}", taskNode);
                return taskNode;
            }
            
            return null;
        } catch (Exception e) {
            log.warn("Failed to parse extracted JSON string: {}", jsonString, e);
            return null;
        }
    }

    /**
     * Populates task DTO from JSON node
     */
    private void populateTaskFromNode(GenerateTasksResponseDTO task, JsonNode taskNode) {
        // Parse id
        if (taskNode.has("id")) {
            task.setId(taskNode.get("id").asLong());
        } else {
            task.setId(1L);
        }
        
        // Parse title
        if (taskNode.has("title")) {
            task.setTitle(taskNode.get("title").asText());
        }
        
        // Parse completed (default to false)
        task.setCompleted(taskNode.has("completed") 
                ? taskNode.get("completed").asBoolean() 
                : false);
        
        // Parse steps
        if (taskNode.has("steps") && taskNode.get("steps").isArray()) {
            List<GenerateTasksResponseDTO.StepFormat> steps = new ArrayList<>();
            for (JsonNode stepNode : taskNode.get("steps")) {
                GenerateTasksResponseDTO.StepFormat step = parseStep(stepNode);
                steps.add(step);
            }
            task.setSteps(steps);
        } else {
            task.setSteps(new ArrayList<>());
        }
    }

    /**
     * Parses a single step from JSON node
     */
    private GenerateTasksResponseDTO.StepFormat parseStep(JsonNode stepNode) {
        GenerateTasksResponseDTO.StepFormat step = new GenerateTasksResponseDTO.StepFormat();
        
        if (stepNode.has("id")) {
            step.setId(stepNode.get("id").asLong());
        }
        
        if (stepNode.has("items")) {
            step.setItems(stepNode.get("items").asText());
        } else if (stepNode.isTextual()) {
            step.setItems(stepNode.asText());
        }
        
        step.setCompleted(stepNode.has("completed") 
                ? stepNode.get("completed").asBoolean() 
                : false);
        
        return step;
    }

    /**
     * Creates a fallback task when JSON parsing fails
     */
    private void createFallbackTask(GenerateTasksResponseDTO task, String textContent, String originalPrompt) {
        log.warn("Could not parse task from response, creating fallback task");
        
        String title = extractTitleFromContent(textContent, originalPrompt);
        
        // Limit title length
        if (title.length() > AIConstants.MAX_TITLE_LENGTH) {
            title = title.substring(0, AIConstants.MAX_TITLE_LENGTH);
        }
        
        task.setId(1L);
        task.setTitle(title);
        task.setCompleted(false);
        task.setSteps(new ArrayList<>());
        
        log.warn("Created fallback task with title: {}", title);
    }

    /**
     * Extracts title from content or uses original prompt
     */
    private String extractTitleFromContent(String textContent, String originalPrompt) {
        if (originalPrompt != null && !originalPrompt.trim().isEmpty()) {
            return originalPrompt.trim();
        }
        
        if (textContent == null || textContent.trim().isEmpty()) {
            return "Generated Task";
        }
        
        // Use first line or first 100 chars as title
        String[] lines = textContent.split("\n");
        if (lines.length > 0 && !lines[0].trim().isEmpty()) {
            String title = lines[0].trim();
            if (title.length() > AIConstants.FALLBACK_TITLE_LENGTH) {
                return title.substring(0, AIConstants.FALLBACK_TITLE_LENGTH);
            }
            return title;
        }
        
        if (textContent.length() > AIConstants.FALLBACK_TITLE_LENGTH) {
            return textContent.substring(0, AIConstants.FALLBACK_TITLE_LENGTH);
        }
        
        return textContent.trim();
    }

    /**
     * Creates an error task when parsing completely fails
     */
    private void createErrorTask(GenerateTasksResponseDTO task) {
        task.setId(1L);
        task.setTitle("Error parsing response");
        task.setCompleted(false);
        task.setSteps(new ArrayList<>());
    }

    /**
     * Saves generated task to database
     *
     * @param generatedTask Task generated by AI
     * @return Saved Todo entity with database ID
     */
    private Todo saveTaskToDatabase(GenerateTasksResponseDTO generatedTask) {
        try {
            TodoRequestDTO todoRequest = convertToTodoRequestDTO(generatedTask);
            return todoService.createTodo(todoRequest);
        } catch (Exception e) {
            log.error("Error saving task to database", e);
            throw new AIServiceException("Failed to save task to database: " + e.getMessage(), e);
        }
    }

    /**
     * Converts GenerateTasksResponseDTO to TodoRequestDTO for database persistence
     */
    private TodoRequestDTO convertToTodoRequestDTO(GenerateTasksResponseDTO generatedTask) {
        TodoRequestDTO todoRequest = new TodoRequestDTO();
        todoRequest.setTitle(generatedTask.getTitle());
        todoRequest.setCompleted(generatedTask.getCompleted());

        if (generatedTask.getSteps() != null && !generatedTask.getSteps().isEmpty()) {
            List<TodoStepRequestDTO> steps = generatedTask.getSteps().stream()
                    .map(step -> {
                        TodoStepRequestDTO stepRequest = new TodoStepRequestDTO();
                        stepRequest.setItems(step.getItems());
                        stepRequest.setCompleted(step.getCompleted());
                        return stepRequest;
                    })
                    .collect(Collectors.toList());
            todoRequest.setSteps(steps);
        }

        return todoRequest;
    }

    /**
     * Converts Todo entity to GenerateTasksResponseDTO with real database IDs
     */
    private GenerateTasksResponseDTO convertToGenerateTasksResponseDTO(Todo todo) {
        GenerateTasksResponseDTO response = new GenerateTasksResponseDTO();
        response.setId(todo.getId());
        response.setTitle(todo.getTitle());
        response.setCompleted(todo.isCompleted());

        if (todo.getSteps() != null && !todo.getSteps().isEmpty()) {
            List<GenerateTasksResponseDTO.StepFormat> steps = todo.getSteps().stream()
                    .map(step -> {
                        GenerateTasksResponseDTO.StepFormat stepFormat = new GenerateTasksResponseDTO.StepFormat();
                        stepFormat.setId(step.getId());
                        stepFormat.setItems(step.getItems());
                        stepFormat.setCompleted(step.isCompleted());
                        return stepFormat;
                    })
                    .collect(Collectors.toList());
            response.setSteps(steps);
        } else {
            response.setSteps(new ArrayList<>());
        }

        return response;
    }
}
