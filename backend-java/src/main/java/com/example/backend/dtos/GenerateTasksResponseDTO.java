package com.example.backend.dtos;

import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Data;
import java.util.List;

/**
 * DTO for task generation responses
 */
@Data
@JsonPropertyOrder({"title", "id", "completed", "steps"})
public class GenerateTasksResponseDTO {
    /**
     * Task ID (typically 1 for generated tasks)
     */
    private Long id;
    
    /**
     * Task title
     */
    private String title;
    
    /**
     * Task completion status (always false for newly generated tasks)
     */
    private Boolean completed;
    
    /**
     * List of steps/subtasks for this task
     */
    private List<StepFormat> steps;
    
    /**
     * Represents a step/subtask within a task
     */
    @Data
    @JsonPropertyOrder({"id", "items", "completed"})
    public static class StepFormat {
        /**
         * Step ID
         */
        private Long id;
        
        /**
         * Step description/items
         */
        private String items;
        
        /**
         * Step completion status (always false for newly generated steps)
         */
        private Boolean completed;
    }
}

