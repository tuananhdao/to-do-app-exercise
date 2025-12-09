package com.example.backend.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class TodoStepUpdateDTO {
    // Accepts JSON key "text" but maps to existing field name.
    @JsonProperty("text")
    private String items;
    private Boolean completed;
}
