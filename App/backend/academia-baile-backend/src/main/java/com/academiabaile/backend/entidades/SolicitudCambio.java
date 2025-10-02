package com.academiabaile.backend.entidades;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class SolicitudCambio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Usuario usuario;

    @Enumerated(EnumType.STRING)
    private TipoSolicitud tipoSolicitud;

    @Column(columnDefinition = "TEXT")
    private String detalle;

    @Enumerated(EnumType.STRING)
    private EstadoSolicitud estado = EstadoSolicitud.PENDIENTE;

    private LocalDateTime fechaCreacion = LocalDateTime.now();

    private LocalDateTime fechaRespuesta;

    private String respuesta;

    public enum TipoSolicitud {
        CAMBIO_CONTRASENA, CAMBIO_USUARIO, OTRO
    }

    public enum EstadoSolicitud {
        PENDIENTE, ATENDIDA, RECHAZADA
    }
}
