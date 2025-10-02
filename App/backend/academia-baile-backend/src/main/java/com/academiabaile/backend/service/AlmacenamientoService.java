package com.academiabaile.backend.service;

import org.springframework.web.multipart.MultipartFile;

public interface AlmacenamientoService {
    String guardar(MultipartFile file);
}
