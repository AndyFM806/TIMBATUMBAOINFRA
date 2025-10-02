package com.academiabaile.backend.entidades;

import jakarta.persistence.*;
import java.util.Set;
import lombok.Getter;
import lombok.Setter;

@Entity
@Setter
@Getter
public class Usuario {
    

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String nombreUsuario;

    private String contrasena;

    private String correoRecuperacion;

    @Enumerated(EnumType.STRING)
    private Rol rol;


    private boolean estado = true;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "usuario_modulo",
        joinColumns = @JoinColumn(name = "usuario_id"),
        inverseJoinColumns = @JoinColumn(name = "modulo_id")
    )
    private Set<ModuloAcceso> modulos;


    @Column(name = "codigo_recuperacion")
    private String codigoRecuperacion;

}
