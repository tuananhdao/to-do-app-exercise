package com.example.backend.dtos;

import lombok.Data;

/**
 * DTO for task generation requests
 */
@Data
public class GenerateTasksRequestDTO {
    /**
     * User prompt describing the task(s) to generate (required)
     */
    private String prompt;
    
    /**
     * Maximum number of tasks to generate (optional)
     * If not provided, defaults to a reasonable limit
     */
    private Integer maxTasks;
}

