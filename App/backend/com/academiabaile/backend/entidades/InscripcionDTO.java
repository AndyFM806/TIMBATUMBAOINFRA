package com.academiabaile.backend.entidades;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InscripcionDTO {
    private String nombres;
    private String apellidos;
    private String correo;
    private String direccion;
    private String dni;
    private Integer claseNivelId;
    private String estado;
    private String metodoPago; // "comprobante" o "pasarela"
    private String codigoNotaCredito;

    public InscripcionDTO() {}
}