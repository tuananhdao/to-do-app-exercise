package com.example.backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.backend.config.APIResponse;
import org.springframework.web.bind.annotation.RequestParam;



@RequestMapping("/api/v1")
@RestController
public class HelloController {

    @GetMapping("/hello")
    public String getHello(){
        return "Hello World";
    }
    @GetMapping("/demo")
    public APIResponse<String> getDemo(){
        return APIResponse.success("This is a demo response");
    }
}
    
