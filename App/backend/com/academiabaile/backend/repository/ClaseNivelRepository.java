package com.academiabaile.backend.repository;

import com.academiabaile.backend.entidades.ClaseNivel;

import jakarta.transaction.Transactional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ClaseNivelRepository extends JpaRepository<ClaseNivel, Integer> {
    List<ClaseNivel> findByFechaCierreAndEstado(LocalDate fechaCierre, String estado);
    List<ClaseNivel> findByClaseId(Integer claseId);
    List<ClaseNivel> findByClaseIdAndEstado(Integer claseId, String estado);
    List<ClaseNivel> findByEstado(String estado);
    Optional<ClaseNivel> findById(Integer id);
@Modifying
@Transactional
@Query(value = "INSERT INTO clase_nivel_horario (clase_nivel_id, horario_id) VALUES (:claseNivelId, :horarioId)", nativeQuery = true)
void insertIntoClaseNivelHorario(@Param("claseNivelId") Integer claseNivelId, @Param("horarioId") Integer horarioId);

@Modifying
@Transactional
@Query(value = "DELETE FROM clase_nivel_horario WHERE clase_nivel_id = :claseNivelId", nativeQuery = true)
void eliminarHorariosDeClaseNivel(@Param("claseNivelId") Integer claseNivelId);
    @Query(value = "SELECT horario_id FROM clase_nivel_horario WHERE clase_nivel_id = :claseNivelId", nativeQuery = true)
    List<Integer> obtenerHorariosPorClaseNivel(@Param("claseNivelId") Integer claseNivelId);

    // En ClaseNivelRepository
    @Query("SELECT c FROM ClaseNivel c WHERE (:desde IS NULL OR c.fechaInicio >= :desde) AND (:hasta IS NULL OR c.fechaInicio <= :hasta)")
    List<ClaseNivel> findByFechaEntre(@Param("desde") LocalDate desde, @Param("hasta") LocalDate hasta);

    @Modifying
    @Transactional
@Query(value = "DELETE FROM clase_nivel_horario WHERE clase_nivel_id = :claseNivelId", nativeQuery = true)
void deleteHorariosByClaseNivelId(@Param("claseNivelId") Integer claseNivelId);


}

