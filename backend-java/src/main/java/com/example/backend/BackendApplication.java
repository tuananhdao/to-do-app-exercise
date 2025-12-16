package com.example.backend;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendApplication {

	public static void main(String[] args) {
		// Load .env file before Spring Boot starts
		Dotenv.configure()
				.ignoreIfMissing()
				.load();

		SpringApplication.run(BackendApplication.class, args);
	}

}
