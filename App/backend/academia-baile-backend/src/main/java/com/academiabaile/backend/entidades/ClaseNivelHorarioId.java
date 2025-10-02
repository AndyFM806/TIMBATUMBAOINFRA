package com.academiabaile.backend.entidades;

import java.io.Serializable;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ClaseNivelHorarioId implements Serializable {

    @Column(name = "clase_nivel_id")
    private Integer claseNivelId;

    @Column(name = "horario_id")
    private Integer horarioId;

    // override equals() and hashCode()
}
