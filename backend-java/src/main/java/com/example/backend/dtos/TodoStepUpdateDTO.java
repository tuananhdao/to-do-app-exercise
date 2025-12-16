package com.example.backend.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class TodoStepUpdateDTO {
    // Accept both "items" and "text" as JSON keys
    @JsonProperty(value = "items")
    private String items;
    
    private Boolean completed;
    
    // Setter to support "text" key as well
    @JsonProperty("text")
    public void setText(String text) {
        this.items = text;
    }
}
