package com.example.backend.repository;

import com.example.backend.model.TodoStep;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TodoStepRepository extends JpaRepository<TodoStep, Long> {
}
