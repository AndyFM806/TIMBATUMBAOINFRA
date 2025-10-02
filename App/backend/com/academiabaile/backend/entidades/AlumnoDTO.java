package com.academiabaile.backend.entidades;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AlumnoDTO {
    private Integer id;
    private String nombres;
    private String correo;
    private String dni;
}
