package com.example.backend.dtos;

import lombok.Data;

import java.util.List;

@Data
public class TodoRequestDTO {
    private String title;
    private Boolean completed;
    private List<TodoStepRequestDTO> steps;

}
