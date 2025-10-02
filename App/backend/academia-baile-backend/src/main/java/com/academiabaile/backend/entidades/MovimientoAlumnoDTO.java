package com.academiabaile.backend.entidades;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MovimientoAlumnoDTO {
    private Integer clienteId;
    private Integer origenClaseNivelId;
    private Integer destinoClaseNivelId;
}