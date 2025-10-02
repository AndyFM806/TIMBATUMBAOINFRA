package com.academiabaile.backend.controller;

import com.academiabaile.backend.entidades.Clase;
import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.ClienteDTO;
import com.academiabaile.backend.entidades.NivelResumenDTO;
import com.academiabaile.backend.repository.ClaseRepository;
import com.academiabaile.backend.service.ClaseService;
import com.academiabaile.backend.service.NivelResumenService;
import com.academiabaile.backend.service.AlumnosPorClaseService;
import com.academiabaile.backend.service.ClaseNivelService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clases")
@CrossOrigin(origins = {"https://timbatumbao-front.onrender.com", "http://localhost:5500"})
public class ClaseController {

    @Autowired
    private ClaseService claseService;

    @Autowired
    private ClaseRepository claseRepository;

    @Autowired
    private ClaseNivelService claseNivelService;

    @Autowired
    private NivelResumenService nivelResumenService;

    @Autowired
    private AlumnosPorClaseService alumnosPorClaseService;

    // ✅ Obtener todas las clases
    @GetMapping
    public List<Clase> listarClases() {
        return claseService.listarClases(); // usa lógica de negocio si aplica
    }

    // ✅ Obtener niveles por clase
    @GetMapping("/{id}/niveles")
public ResponseEntity<List<ClaseNivel>> obtenerNivelesAbiertosPorClase(@PathVariable Integer id) {
    List<ClaseNivel> abiertos = claseNivelService.findByClaseIdAndEstado(id, "abierta");
    return ResponseEntity.ok(abiertos);
}

    // ✅ Obtener resumen de niveles por clase
    @GetMapping("/{id}/niveles-resumen")
    public ResponseEntity<List<NivelResumenDTO>> obtenerResumenNiveles(@PathVariable Integer id) {
        return ResponseEntity.ok(nivelResumenService.obtenerResumenNivelesPorClase(id));
    }

    // ✅ Obtener alumnos por clase (según ID de claseNivel)
    @GetMapping("/{id}/alumnos")
    public ResponseEntity<List<ClienteDTO>> listarAlumnosPorClaseNivel(@PathVariable Integer id) {
        return ResponseEntity.ok(alumnosPorClaseService.obtenerAlumnosPorClaseNivel(id));
    }

    // ✅ Cerrar clase
    @PostMapping("/{id}/cerrar")
    public ResponseEntity<?> cerrarClaseNivel(@PathVariable Integer id) {
        try {
            claseNivelService.cerrarClaseNivel(id);
            return ResponseEntity.ok("Clase cerrada correctamente");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // ✅ Crear nueva clase
    @PostMapping
    public Clase crear(@RequestBody Clase c) {
        return claseRepository.save(c);
    }

    // ✅ Editar clase existente
    @PutMapping("/{id}")
    public Clase editar(@PathVariable int id, @RequestBody Clase c) {
        c.setId(id);
        return claseRepository.save(c);
    }

    // ✅ Eliminar clase
    @DeleteMapping("/{id}")
    public void eliminar(@PathVariable int id) {
        claseRepository.deleteById(id);
    }
}
