package com.academiabaile.backend.entidades;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Nivel {

    @Id
    @Column(name = "id_nivel")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String nombre;
}


