package com.academiabaile.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.academiabaile.backend.entidades.ClaseNivelHorario;
import com.academiabaile.backend.entidades.ClaseNivelHorarioId;

public interface ClaseNivelHorarioRepository extends JpaRepository<ClaseNivelHorario, ClaseNivelHorarioId> {
    int countByHorarioIdAndClaseNivel_Aula_Id(Integer horarioId, Integer aulaId);
    List<ClaseNivelHorario> findByClaseNivelId(Integer claseNivelId);
}
