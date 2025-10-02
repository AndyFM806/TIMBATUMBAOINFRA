package com.academiabaile.backend.controller;

import com.academiabaile.backend.entidades.Horario;
import com.academiabaile.backend.repository.HorarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/horarios")
@CrossOrigin(origins = {"http://localhost:5500", "https://timbatumbao-front.onrender.com"})
public class HorarioController {

    @Autowired
    private HorarioRepository horarioRepository;

    @GetMapping
    public List<Horario> listar() {
        return horarioRepository.findAll();
    }

    @PostMapping
    public Horario crear(@RequestBody Horario h) {
        return horarioRepository.save(h);
    }

    @PutMapping("/{id}")
    public Horario editar(@PathVariable Integer id, @RequestBody Horario h) {
        h.setId(id);
        return horarioRepository.save(h);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Integer id) {
        horarioRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
}
