package com.academiabaile.backend.controller;

import com.academiabaile.backend.entidades.*;
import com.academiabaile.backend.repository.InscripcionRepository;
import com.academiabaile.backend.service.*;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/inscripciones")
public class InscripcionController {

    @Autowired private InscripcionService inscripcionService;
    @Autowired private InscripcionRepository inscripcionRepository;
    @Autowired private AlmacenamientoService almacenamientoService;
    @Autowired private MercadoPagoRestService mpService;
    @Autowired private EmailService emailService;
    
    @PostMapping("/{id}/enviar-bienvenida")
    public ResponseEntity<?> enviarCorreoBienvenida(@PathVariable Integer id) {
        Inscripcion insc = inscripcionRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

        emailService.enviarCorreo(
            insc.getCliente().getCorreo(),
            "¡Inscripción aprobada y bienvenida!",
            String.format("Hola %s,\n\n¡Tu inscripción ha sido aprobada! Bienvenido/a a nuestra academia. Te esperamos en la clase '%s - %s'.",
                insc.getCliente().getNombres(),
                insc.getClaseNivel().getClase().getNombre(),
                insc.getClaseNivel().getNivel().getNombre()
            )
        );

        return ResponseEntity.ok("Correo de bienvenida enviado");
    }
    // 1. Registrar inscripción
    @PostMapping
    public ResponseEntity<?> registrar(@RequestBody InscripcionDTO dto) {
        try {
            Integer id = inscripcionService.registrar(dto);

            emailService.enviarCorreo(
                dto.getCorreo(),
                "Registro de inscripción recibido",
                "Hola " + dto.getNombres() + ", hemos recibido tu solicitud de inscripción. Te confirmaremos pronto."
            );

            return ResponseEntity.ok("Inscripción registrada con ID: " + id);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 2. Subir comprobante
    @PostMapping("/comprobante/{id}")
    public ResponseEntity<?> subirComprobante(@PathVariable Integer id, @RequestParam("file") MultipartFile file) {
        String url = almacenamientoService.guardar(file);

        Inscripcion insc = inscripcionRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

        insc.setComprobanteUrl(url);
        inscripcionRepository.save(insc);

        return ResponseEntity.ok("Comprobante subido");
    }

    // 3. Aprobar inscripción manual
    @PatchMapping("/{id}/aprobar-manual")
    public ResponseEntity<?> aprobarInscripcion(@PathVariable Integer id) {
        Inscripcion insc = inscripcionRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

        if (!"pendiente".equalsIgnoreCase(insc.getEstado())) {
            return ResponseEntity.badRequest().body("Esta inscripción ya fue procesada");
        }

        insc.setEstado("aprobada");
        inscripcionRepository.save(insc);

        emailService.enviarCorreo(
            insc.getCliente().getCorreo(),
            "Inscripción aprobada - Timba Tumbao",
            String.format("Hola %s,\n\nTu inscripción en la clase '%s - %s' ha sido aprobada. ¡Te esperamos!",
                insc.getCliente().getNombres(),
                insc.getClaseNivel().getClase().getNombre(),
                insc.getClaseNivel().getNivel().getNombre()
            )
        );

        return ResponseEntity.ok("Inscripción aprobada");
    }

    // 4. Rechazar inscripción
    @PatchMapping("/{id}/rechazar")
    public ResponseEntity<?> rechazarInscripcion(@PathVariable Integer id) {
        Inscripcion insc = inscripcionRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

        if (!"pendiente".equalsIgnoreCase(insc.getEstado())) {
            return ResponseEntity.badRequest().body("Esta inscripción ya fue procesada");
        }

        insc.setEstado("rechazada");
        inscripcionRepository.save(insc);


        emailService.enviarCorreo(
            insc.getCliente().getCorreo(),
            "Inscripción rechazada - Timba Tumbao",
            String.format("Hola %s,\n\nLamentamos informarte que tu inscripción en la clase '%s - %s' fue rechazada. Puedes intentarlo nuevamente o contactarnos para más información.",
                insc.getCliente().getNombres(),
                insc.getClaseNivel().getClase().getNombre(),
                insc.getClaseNivel().getNivel().getNombre()
            )
        );

        return ResponseEntity.ok("Inscripción rechazada");
    }

    // 5. Generar link de pago Mercado Pago
    @PostMapping("/generar-pago/{inscripcionId}")
    public ResponseEntity<?> generarPago(@PathVariable Integer inscripcionId) {
        Inscripcion insc = inscripcionRepository.findById(inscripcionId)
    .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

    if ("aprobada".equalsIgnoreCase(insc.getEstado())) {
        throw new RuntimeException("La inscripción ya fue aprobada y no requiere pago.");
    }

        String nombreClase = insc.getClaseNivel().getClase().getNombre() + " - " + insc.getClaseNivel().getNivel().getNombre();
        double monto = insc.getEstado().equalsIgnoreCase("pendiente_pago_diferencia") && insc.getMontoPendiente() != null
            ? insc.getMontoPendiente()
            : insc.getClaseNivel().getPrecio();

        if (monto <= 0) {
            throw new RuntimeException("Monto inválido para generar pago.");
        }

        String urlPago = mpService.crearPreferencia(monto,nombreClase, inscripcionId);
        return ResponseEntity.ok(urlPago);
    }

    // 6. Completar pago de diferencia (comprobante o pasarela)
    @PostMapping("/completar-pago-diferencia")
    public ResponseEntity<?> completarPagoDiferencia(@RequestParam Integer id,
                                                     @RequestParam String metodo,
                                                     @RequestParam(required = false) String comprobanteUrl) {
        try {
            inscripcionService.completarPagoDiferencia(id, metodo, comprobanteUrl);
            return ResponseEntity.ok("Pago completado");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 7. Listar inscripciones pendientes con comprobante
    @GetMapping("/pendientes-con-comprobante")
    public ResponseEntity<?> listarPendientesConComprobante() {
        List<Inscripcion> lista = inscripcionRepository.findByEstadoAndComprobanteUrlIsNotNull("pendiente");


        return ResponseEntity.ok(lista);
    }

    // 8. Listar inscripciones pendientes de diferencia
    @GetMapping("/pendientes-diferencia")
    public ResponseEntity<?> listarPendientesDiferencia() {
        List<Inscripcion> lista = inscripcionRepository
            .findByEstadoAndNotaCreditoIsNotNullAndMontoPendienteGreaterThan("pendiente_pago_diferencia", 0.0);
        return ResponseEntity.ok(lista);
    }

    // 9. Listar todas las inscripciones
    @GetMapping
    public ResponseEntity<?> listarTodas() {
        return ResponseEntity.ok(inscripcionRepository.findAll());
    }

    @PostMapping("/manual")
    public ResponseEntity<?> inscribirManual(@RequestBody InscripcionDTO dto) {
        try {
            Integer id = inscripcionService.registrarManual(dto);
            return ResponseEntity.ok(Map.of("inscripcionId", id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    @PostMapping("/mover")
public ResponseEntity<?> moverCliente(@RequestBody MovimientoClienteDTO dto) {
    try {
        inscripcionService.moverCliente(dto);
        return ResponseEntity.ok("Cliente movido correctamente");
    } catch (RuntimeException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }
}
    @GetMapping("/aprobadas")
public ResponseEntity<List<Inscripcion>> obtenerInscripcionesAprobadas() {
    List<Inscripcion> aprobadas = inscripcionRepository.findByEstadoIgnoreCase("aprobada");
    return ResponseEntity.ok(aprobadas);
}
    @GetMapping("/{id}/saldo")
    public ResponseEntity<SaldoInscripcionDTO> obtenerSaldo(@PathVariable Integer id) {
        SaldoInscripcionDTO dto = inscripcionService.calcularSaldo(id);
        return ResponseEntity.ok(dto);
    }

}
