package com.academiabaile.backend.config;
    
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins(
                            "https://timbatumbao-front.onrender.com",
                            "http://localhost:5500"
                        )
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS") // 👈 AÑADIDO
                        .allowedHeaders("*")
                        .allowCredentials(true);
            }
        };
    }
}
