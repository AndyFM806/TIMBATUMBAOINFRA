package com.academiabaile.backend.service;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import com.academiabaile.backend.entidades.InscripcionDTO;
import com.academiabaile.backend.entidades.MovimientoClienteDTO;
import com.academiabaile.backend.entidades.NotaCredito;
import com.academiabaile.backend.entidades.SaldoInscripcionDTO;
import com.academiabaile.backend.entidades.Cliente;
import com.academiabaile.backend.entidades.Inscripcion;
import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.repository.ClienteRepository;
import com.academiabaile.backend.repository.ClaseNivelRepository;
import com.academiabaile.backend.repository.InscripcionRepository;


    @Service
public class InscripcionServiceImpl implements InscripcionService {


    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private ClaseNivelRepository claseNivelRepository;

    @Autowired
    private InscripcionRepository inscripcionRepository;

    @Autowired
    private NotaCreditoService notaCreditoService;

    @Autowired
    private EmailService emailService;

@Override
public Integer registrar(InscripcionDTO dto) {
    ClaseNivel claseNivel = claseNivelRepository.findById(dto.getClaseNivelId())
        .orElseThrow(() -> new RuntimeException("ClaseNivel no encontrada"));

    // Validar aforo
    int inscritos = inscripcionRepository.countByClaseNivelAndEstado(claseNivel, "aprobada");
    if (inscritos >= claseNivel.getAforo()) {
        throw new RuntimeException("Clase llena");
    }

    // Obtener o crear cliente por DNI
    Optional<Cliente> clienteOpt = clienteRepository.findByDni(dto.getDni());
    Cliente cliente;

    if (clienteOpt.isPresent()) {
        cliente = clienteOpt.get();

        // 🔒 Verificar conflicto de horario con inscripción aprobada
        List<Integer> horariosClaseNivel = claseNivelRepository.obtenerHorariosPorClaseNivel(claseNivel.getId());

        boolean conflictoHorario = inscripcionRepository
            .existeConflictoHorarios(cliente.getId(), horariosClaseNivel, "aprobada");

        if (conflictoHorario) {
            throw new RuntimeException("El cliente ya está inscrito en una clase con alguno de estos horarios.");
        }


        // 🔒 Verificar duplicidad exacta en clase y nivel
        boolean yaInscrito = inscripcionRepository.existsByClienteAndClaseNivelAndEstado(
            cliente, claseNivel, "aprobada"
        );
        if (yaInscrito) {
            throw new RuntimeException("El cliente ya tiene una inscripción aprobada en esta clase.");
        }

    } else {
        // Crear cliente nuevo
        cliente = new Cliente();
        cliente.setDni(dto.getDni());
        cliente.setNombres(dto.getNombres());
        cliente.setApellidos(dto.getApellidos());
        cliente.setCorreo(dto.getCorreo());
        cliente.setDireccion(dto.getDireccion());
        cliente = clienteRepository.save(cliente);
    }

    // Crear inscripción
    Inscripcion inscripcion = new Inscripcion();
    inscripcion.setCliente(cliente);
    inscripcion.setClaseNivel(claseNivel);
    inscripcion.setFechaInscripcion(LocalDate.now().atStartOfDay());

    // Nota de crédito
    if (dto.getCodigoNotaCredito() != null && !dto.getCodigoNotaCredito().isEmpty()) {
        NotaCredito nota = notaCreditoService.validarNota(dto.getCodigoNotaCredito());
        double precioClase = claseNivel.getPrecio();

        if (nota.getValor() >= precioClase) {
            notaCreditoService.marcarComoUsada(nota);
            inscripcion.setEstado("aprobada");
            inscripcion.setNotaCredito(nota);

            emailService.enviarCorreo(cliente.getCorreo(),
                "Inscripción completada con nota de crédito",
                "Tu inscripción a la clase " + claseNivel.getClase().getNombre() +
                " fue completada usando el código: " + nota.getCodigo() +
                ". No necesitas realizar ningún pago adicional.");
        } else {
            double diferencia = precioClase - nota.getValor();
            inscripcion.setEstado("pendiente_pago_diferencia");
            inscripcion.setMontoPendiente(diferencia);
            inscripcion.setNotaCredito(nota);
        }
    } else {
        inscripcion.setEstado("pendiente");
    }

    inscripcionRepository.save(inscripcion);
    return inscripcion.getId();
}


    @Override
    public void completarPagoDiferencia(Integer inscripcionId, String metodo, String comprobanteUrl) {
    Inscripcion inscripcion = inscripcionRepository.findById(inscripcionId)
        .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

    if (!"pendiente_pago_diferencia".equalsIgnoreCase(inscripcion.getEstado())) {
        throw new RuntimeException("La inscripción no está pendiente de pago de diferencia");
    }

    if ("comprobante".equalsIgnoreCase(metodo)) {
        inscripcion.setComprobanteUrl(comprobanteUrl);
        inscripcion.setEstado("pendiente_aprobacion_comprobante");


    } else if ("mercado_pago".equalsIgnoreCase(metodo)) {
        inscripcion.setEstado("aprobada");

        if (inscripcion.getNotaCredito() != null && !inscripcion.getNotaCredito().getUsada()) {
            notaCreditoService.marcarComoUsada(inscripcion.getNotaCredito());
        }

        emailService.enviarCorreo(
            inscripcion.getCliente().getCorreo(),
            "Inscripción completada",
            "Tu inscripción a la clase " + inscripcion.getClaseNivel().getClase().getNombre() +
            " fue aprobada tras completar el pago de diferencia con Mercado Pago."
        );

    }

    inscripcionRepository.save(inscripcion);
}

    @Override
public Integer registrarManual(InscripcionDTO dto) {
    ClaseNivel claseNivel = claseNivelRepository.findById(dto.getClaseNivelId())
        .orElseThrow(() -> new RuntimeException("ClaseNivel no encontrada"));

    int inscritos = inscripcionRepository.countByClaseNivelAndEstado(claseNivel, "aprobada");
    if (inscritos >= claseNivel.getAforo()) {
        throw new RuntimeException("La clase está llena");
        
    }

    Cliente cliente = clienteRepository.findByDni(dto.getDni())
        .orElseGet(() -> {
            Cliente nuevo = new Cliente();
            nuevo.setDni(dto.getDni());
            nuevo.setNombres(dto.getNombres());
            nuevo.setApellidos(dto.getApellidos());
            nuevo.setCorreo(dto.getCorreo());
            return clienteRepository.save(nuevo);
        });

    if (inscripcionRepository.existsByClienteAndClaseNivel(cliente, claseNivel)) {
        throw new RuntimeException("El cliente ya está inscrito en esta clase");
    }

    Inscripcion inscripcion = new Inscripcion();
    inscripcion.setCliente(cliente);
    inscripcion.setClaseNivel(claseNivel);
    inscripcion.setFechaInscripcion(LocalDate.now().atStartOfDay());
    inscripcion.setEstado("aprobada");

    inscripcionRepository.save(inscripcion);

    emailService.enviarCorreo(
        cliente.getCorreo(),
        "Inscripción manual confirmada",
        "Has sido inscrito manualmente a la clase: " + claseNivel.getClase().getNombre() +
        " en el nivel " + claseNivel.getNivel().getNombre() + ". ¡Te esperamos!");


    return inscripcion.getId();
}

@Override
public void moverCliente(MovimientoClienteDTO dto) {
    Cliente cliente = clienteRepository.findByDni(dto.getDni())
        .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));

    ClaseNivel origen = claseNivelRepository.findById(dto.getClaseOrigenId())
        .orElseThrow(() -> new RuntimeException("Clase origen no encontrada"));

    ClaseNivel destino = claseNivelRepository.findById(dto.getClaseDestinoId())
        .orElseThrow(() -> new RuntimeException("Clase destino no encontrada"));

    // Buscar inscripción actual
    Inscripcion inscripcionActual = inscripcionRepository.findByClienteAndClaseNivel(cliente, origen);
    if (inscripcionActual == null) {
        throw new RuntimeException("El cliente no está inscrito en la clase origen");
    }

    if (inscripcionRepository.existsByClienteAndClaseNivel(cliente, destino)) {
        throw new RuntimeException("El cliente ya está inscrito en la clase destino");
    }

    int inscritosDestino = inscripcionRepository.countByClaseNivelAndEstado(destino, "aprobada");
    if (inscritosDestino >= destino.getAforo()) {
        throw new RuntimeException("La clase destino está llena");
    }

    // Cancelar inscripción anterior
    inscripcionActual.setEstado("movida");
    inscripcionRepository.save(inscripcionActual);

    // Crear nueva inscripción
    Inscripcion nuevaInscripcion = new Inscripcion();
    nuevaInscripcion.setCliente(cliente);
    nuevaInscripcion.setClaseNivel(destino);
    nuevaInscripcion.setFechaInscripcion(LocalDate.now().atStartOfDay());
    nuevaInscripcion.setEstado("aprobada");

    inscripcionRepository.save(nuevaInscripcion);

    emailService.enviarCorreo(
        cliente.getCorreo(),
        "Has sido reubicado de clase",
        "Tu inscripción ha sido actualizada. Ahora estás inscrito en la clase " +
        destino.getClase().getNombre() + " - Nivel: " + destino.getNivel().getNombre());



}
@Override
public SaldoInscripcionDTO calcularSaldo(Integer inscripcionId) {
    Inscripcion inscripcion = inscripcionRepository.findById(inscripcionId)
        .orElseThrow(() -> new RuntimeException("Inscripción no encontrada"));

    double total = inscripcion.getClaseNivel().getPrecio();
    double valorNotaCredito = inscripcion.getNotaCredito() != null ? inscripcion.getNotaCredito().getValor() : 0.0;

    return new SaldoInscripcionDTO(inscripcionId, total, valorNotaCredito);
}

}
