package com.academiabaile.backend.controller;

import com.academiabaile.backend.entidades.Nivel;
import com.academiabaile.backend.repository.NivelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/niveles")
@CrossOrigin(origins = {"http://localhost:5500", "https://timbatumbao-front.onrender.com"})
public class NivelController {

    @Autowired
    private NivelRepository nivelRepository;

    @GetMapping
    public List<Nivel> listar() {
        return nivelRepository.findAll();
    }

    @PostMapping
    public Nivel crear(@RequestBody Nivel nivel) {
        return nivelRepository.save(nivel);
    }

    @PutMapping("/{id}")
    public Nivel editar(@PathVariable Integer id, @RequestBody Nivel nivel) {
        nivel.setId(id);
        return nivelRepository.save(nivel);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Integer id) {
        nivelRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
}
