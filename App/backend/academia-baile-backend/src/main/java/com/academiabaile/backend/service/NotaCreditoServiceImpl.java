package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.*;
import com.academiabaile.backend.repository.NotaCreditoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.UUID;

@Service
public class NotaCreditoServiceImpl implements NotaCreditoService {


    @Autowired
    private NotaCreditoRepository notaCreditoRepository;

    @Override
    public NotaCredito generarNotaCredito(Cliente cliente, Double valor, ClaseNivel claseCancelada) {
        NotaCredito nota = new NotaCredito();
        nota.setCliente(cliente);
        nota.setValor(valor);
        nota.setCodigo(UUID.randomUUID().toString().substring(0, 10));
        nota.setFechaEmision(LocalDate.now());
        nota.setFechaExpiracion(LocalDate.now().plusMonths(6));
        nota.setClaseCancelada(claseCancelada);
       
        return notaCreditoRepository.save(nota);
    }

    @Override
public void marcarComoUsada(NotaCredito notaCredito) {
    NotaCredito nota = notaCreditoRepository.findById(notaCredito.getId())
            .orElseThrow(() -> new IllegalArgumentException("Nota de crédito no encontrada"));



    nota.setUsada(true);
    notaCreditoRepository.save(nota);
}
public NotaCredito validarNota(String codigo) {
    NotaCredito nota = notaCreditoRepository.findByCodigo(codigo)
            .orElseThrow(() -> new RuntimeException("Código de nota de crédito inválido"));

    if (nota.getUsada()) {
        throw new RuntimeException("La nota de crédito ya fue usada");
    }

    if (nota.getFechaExpiracion().isBefore(LocalDate.now())) {
        throw new RuntimeException("La nota de crédito está vencida");
    }

    return nota;
}
@Autowired
private EmailService emailService;
    @Override
    public NotaCredito crearNotaCreditoNueva(Cliente cliente, Double valor, LocalDate fechaEmision, LocalDate fechaExpiracion, ClaseNivel claseCancelada) {
    NotaCredito nota = new NotaCredito();
    nota.setCliente(cliente);
    nota.setValor(valor);
    nota.setFechaEmision(fechaEmision);
    nota.setFechaExpiracion(fechaExpiracion);
    nota.setCodigo(UUID.randomUUID().toString().substring(0, 10));
    nota.setClaseCancelada(claseCancelada); // ✅ ¡Esto es lo que faltaba!
        emailService.enviarCorreo(
            cliente.getCorreo(),
            "Nueva Nota de Crédito - Academia de Baile",
            String.format("Hola %s,\n\nSe ha generado una nueva nota de crédito por un valor de %.2f. " +
                            "Puedes usarla para futuras inscripciones.\n\nCódigo: %s\nFecha de emisión: %s\nFecha de expiración: %s",
                    cliente.getNombres(),
                    valor,
                    nota.getCodigo(),
                    fechaEmision,
                    fechaExpiracion)
        );
    return notaCreditoRepository.save(nota);
}


    
}
