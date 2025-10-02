package com.academiabaile.backend.entidades;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
@Entity
@Getter
@Setter
public class Horario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String dias;
    private String hora;

    // Getters y setters
}


