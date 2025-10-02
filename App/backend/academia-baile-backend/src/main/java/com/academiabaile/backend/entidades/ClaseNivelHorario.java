package com.academiabaile.backend.entidades;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "clase_nivel_horario")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ClaseNivelHorario {

    @EmbeddedId
    private ClaseNivelHorarioId id;

    @ManyToOne
    @MapsId("claseNivelId")
    @JoinColumn(name = "clase_nivel_id")
    private ClaseNivel claseNivel;

    @ManyToOne
    @MapsId("horarioId")
    @JoinColumn(name = "horario_id")
    private Horario horario;
}
