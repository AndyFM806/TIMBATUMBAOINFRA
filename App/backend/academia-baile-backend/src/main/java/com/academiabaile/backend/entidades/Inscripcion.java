package com.academiabaile.backend.entidades;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "inscripcion")
@Data
public class Inscripcion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String estado = "pendiente";

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    @ManyToOne
    @JoinColumn(name = "clase_nivel_id")
    private ClaseNivel claseNivel;

    @Column(name = "fecha_inscripcion", updatable = false)
    private LocalDateTime fechaInscripcion;

    @PrePersist
    protected void onCreate() {
        this.fechaInscripcion = LocalDateTime.now();
    }

    @Column(name = "comprobante_url")
    private String comprobanteUrl;

    @ManyToOne
    private NotaCredito notaCredito;

    private Double montoPendiente;
    public void setFechaInscripcion(LocalDateTime fechaInscripcion) {
    this.fechaInscripcion = fechaInscripcion;
}

}
