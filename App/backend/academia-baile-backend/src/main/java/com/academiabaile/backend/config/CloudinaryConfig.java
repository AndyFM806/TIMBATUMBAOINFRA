package com.academiabaile.backend.config;
import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class CloudinaryConfig {

    @Bean
    public Cloudinary cloudinary() {
        return new Cloudinary(ObjectUtils.asMap(
            "cloud_name", "dblklvzrg",
            "api_key", "714831947891749",
            "api_secret", "hGlU0mBlHDCK57ANNJKczGdItBo",
            "secure", true
        ));
    }
}