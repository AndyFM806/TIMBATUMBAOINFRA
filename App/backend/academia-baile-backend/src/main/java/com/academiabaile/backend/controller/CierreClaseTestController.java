package com.academiabaile.backend.controller;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.http.ResponseEntity;
import com.academiabaile.backend.service.ClaseNivelService;
import com.academiabaile.backend.repository.ClaseNivelRepository;
import com.academiabaile.backend.entidades.ClaseNivel;

@RestController
@RequestMapping("/api/test-cierre")
public class CierreClaseTestController {

    @Autowired
    private ClaseNivelService claseNivelService;

    @Autowired
    private ClaseNivelRepository claseNivelRepository;

    @GetMapping("/{id}")
    public ResponseEntity<?> testCierre(@PathVariable Integer id) {
        ClaseNivel claseNivel = claseNivelRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("ClaseNivel no encontrado"));

        claseNivelService.cerrarClaseSiNoLlegaAlMinimo(claseNivel);

        return ResponseEntity.ok("Verificación de cierre completada para claseNivel ID: " + id);
    }
}
