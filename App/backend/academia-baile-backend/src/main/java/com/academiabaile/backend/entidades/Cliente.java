package com.academiabaile.backend.entidades;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
@Entity
@Getter
@Setter
@Table(name = "cliente")
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "anotacion", columnDefinition = "TEXT")
    private String anotacion;

    @Column(name = "nombres")
    private String nombres;

    @Column(name = "apellidos")
    private String apellidos;

    @Column(name = "correo")
    private String correo;

    @Column(name = "direccion")
    private String direccion;

    @Column(name = "dni", nullable = false, unique = true)
    private String dni;

    // No más relación directa con claseNivel
}
