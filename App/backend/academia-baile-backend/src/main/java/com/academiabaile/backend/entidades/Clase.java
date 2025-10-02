package com.academiabaile.backend.entidades;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "clase")
public class Clase {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_clase")
    private Integer id;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(columnDefinition = "TEXT")
    private String descripcion;
}
