package com.academiabaile.backend.entidades;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CeldaHorarioDTO {
    private String dia;
    private String hora;
    private String aula; // Ej: A1, A2, etc.
    private boolean ocupado;
    private String clase;  // Ej: "Salsa - Básico"
    private String estado; // abierta, cerrada, cancelada, etc.
    private Integer horarioId;
    private Integer aulaId;
    private Integer claseNivelId;
}
