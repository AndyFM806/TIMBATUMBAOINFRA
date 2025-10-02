package com.academiabaile.backend.entidades;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NotaCreditoRequest {
    private Double valor;  // requerido para emitir nota de crédito manual
}
