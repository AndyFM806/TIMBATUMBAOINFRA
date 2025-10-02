package com.academiabaile.backend.entidades;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MovimientoClienteDTO {
    private String dni;
    private Integer claseOrigenId;
    private Integer claseDestinoId;
}
