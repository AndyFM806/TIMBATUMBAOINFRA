package com.academiabaile.backend.entidades;

import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class ClaseNivel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "clase_id")
    private Clase clase;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "nivel_id")
    private Nivel nivel;

    @ManyToMany
    @JoinTable(
    name = "clase_nivel_horario",
    joinColumns = @JoinColumn(name = "clase_nivel_id"),
    inverseJoinColumns = @JoinColumn(name = "horario_id")
    )
    private List<Horario> horarios;


    @Column(nullable = false)
    private int aforo;

    private Double precio;

    @Column(nullable = false)
    private String estado;

    @Column(name = "motivo_cancelacion")
    private String motivoCancelacion;
    @Column(name = "fecha_cierre")
    private LocalDate fechaCierre;
    
            @ManyToOne
        private Aula aula;
        @Column(name = "fecha_inicio")
        private LocalDate fechaInicio;

        @Column(name = "fecha_fin")
        private LocalDate fechaFin;
    @Column(name = "distintivo")
    private String distintivo;
    }





