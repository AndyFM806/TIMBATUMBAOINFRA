package com.academiabaile.backend.entidades;

import jakarta.persistence.*;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class NotaCredito {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String codigo;

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    private Cliente cliente;

    private Double valor;

    private LocalDate fechaEmision;
    private LocalDate fechaExpiracion;

    @ManyToOne
@JoinColumn(name = "clase_cancelada_id", nullable = true) // ✅ ahora puede ser null
private ClaseNivel claseCancelada;

    private Boolean usada = false;

}

