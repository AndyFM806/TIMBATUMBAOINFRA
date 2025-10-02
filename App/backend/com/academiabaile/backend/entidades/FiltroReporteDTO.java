package com.academiabaile.backend.entidades;

import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;
@Getter
@Setter
public class FiltroReporteDTO {
    private String tipoEvento; // opcional
    private String modulo;     // opcional
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}
