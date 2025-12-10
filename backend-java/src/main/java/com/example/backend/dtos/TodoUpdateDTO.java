package com.example.backend.dtos;

import lombok.Data;

@Data
public class TodoUpdateDTO {
    private String title;
    private Boolean completed;
}
