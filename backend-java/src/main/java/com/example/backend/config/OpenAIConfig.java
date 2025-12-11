package com.example.backend.config;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class OpenAIConfig {

    @Value("${openai.api.key:#{null}}")
    private String configApiKey;

    @Value("${openai.api.base-url:https://generativelanguage.googleapis.com/v1beta/openai}")
    private String configApiBaseUrl;

    @Bean
    public Dotenv dotenv() {
        return Dotenv.configure()
                .ignoreIfMissing()
                .load();
    }

    @Bean
    public WebClient webClient() {
        return WebClient.builder()
                .build();
    }

    @Bean
    public String openAiApiKey(Dotenv dotenv) {
        // Priority: Spring properties > .env file
        String apiKey = configApiKey;
        if (apiKey == null || apiKey.isEmpty()) {
            apiKey = dotenv.get("OPENAI_API_KEY");
        }
        if (apiKey == null || apiKey.isEmpty()) {
            throw new IllegalStateException("OPENAI_API_KEY environment variable is not set");
        }
        return apiKey;
    }

    @Bean
    public String openAiApiBaseUrl(Dotenv dotenv) {
        // Priority: Spring properties > .env file
        if (configApiBaseUrl != null && !configApiBaseUrl.isEmpty()) {
            return configApiBaseUrl;
        }
        return dotenv.get("OPENAI_API_BASE_URL", "https://generativelanguage.googleapis.com/v1beta/openai");
    }
}

