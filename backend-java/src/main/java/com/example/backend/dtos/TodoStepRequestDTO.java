package com.example.backend.dtos;

import lombok.Data;

@Data
public class TodoStepRequestDTO {
    private String items;
    private Boolean completed;
}
