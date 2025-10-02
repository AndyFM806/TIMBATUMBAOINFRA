package com.academiabaile.backend.controller;

import com.academiabaile.backend.entidades.ClienteDTO;
import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.MovimientoAlumnoDTO;
import com.academiabaile.backend.entidades.NotaCredito;
import com.academiabaile.backend.service.AlumnoService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/alumnos")
@CrossOrigin(origins = {"http://localhost:5500", "https://timbatumbao-front.onrender.com"})
public class AlumnoController {

    @Autowired
    private AlumnoService alumnoService;

    // ✅ Listar clases en las que está inscrito el alumno
    @GetMapping("/{id}/clases")
    public ResponseEntity<List<ClaseNivel>> listarClases(@PathVariable Integer id) {
        return ResponseEntity.ok(alumnoService.listarClasesDeAlumno(id));
    }

    // ✅ Inscribir alumno directamente a una claseNivel
    @PostMapping("/inscribir")
    public ResponseEntity<?> inscribir(@RequestParam Integer clienteId, @RequestParam Integer claseNivelId) {
        alumnoService.inscribirAlumnoEnClase(clienteId, claseNivelId);
        return ResponseEntity.ok("Alumno inscrito correctamente");
    }

    // ✅ Eliminar alumno de una claseNivel
    @DeleteMapping("/{clienteId}/clase/{claseNivelId}")
    public ResponseEntity<?> eliminarDeClase(@PathVariable Integer clienteId, @PathVariable Integer claseNivelId) {
        alumnoService.eliminarAlumnoDeClase(clienteId, claseNivelId);
        return ResponseEntity.ok("Alumno eliminado de clase");
    }

    // ✅ Mover alumno entre clases
    @PostMapping("/mover")
    public ResponseEntity<?> moverAlumno(@RequestBody MovimientoAlumnoDTO dto) {
        alumnoService.moverAlumno(dto);
        return ResponseEntity.ok("Alumno movido correctamente");
    }

    // ✅ Obtener datos personales del alumno
    @GetMapping("/{id}/datos")
    public ResponseEntity<ClienteDTO> obtenerDatos(@PathVariable Integer id) {
        return ResponseEntity.ok(alumnoService.obtenerDatosDelAlumno(id));
    }

    // ✅ Actualizar datos personales del alumno
    @PutMapping("/{id}/datos")
    public ResponseEntity<?> actualizarDatos(@PathVariable Long id, @RequestBody ClienteDTO dto) {
        dto.setId(id); // asegurarse de tener el ID correcto
        alumnoService.actualizarDatosCliente(dto);
        return ResponseEntity.ok("Datos actualizados correctamente");
    }

    // ✅ Generar nota de crédito manualmente
    @PostMapping("/{clienteId}/nota-credito")
    public ResponseEntity<NotaCredito> generarNotaCredito(@PathVariable Integer clienteId, @RequestParam Double valor) {
        NotaCredito nota = alumnoService.generarManualNotaCredito(clienteId, valor);
        return ResponseEntity.ok(nota);
    }
    @GetMapping("/{id}/clases-disponibles")
    public ResponseEntity<List<ClaseNivel>> listarClasesNoInscritas(@PathVariable Integer id) {
    return ResponseEntity.ok(alumnoService.listarClasesNoInscritas(id));
}

}
