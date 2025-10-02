package com.academiabaile.backend.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.Cliente;
import com.academiabaile.backend.entidades.Inscripcion;

public interface InscripcionRepository extends JpaRepository<Inscripcion, Integer>{
    int countByClaseNivelAndEstado(ClaseNivel claseNivel, String estado); // para validar aforo
    List<Inscripcion> findByEstadoAndComprobanteUrlIsNotNull(String estado);
    boolean existsByClienteAndClaseNivel(Cliente cliente, ClaseNivel claseNivel);
    List<Inscripcion> findByClaseNivel_IdInAndEstado(List<Integer> claseNivelIds, String estado);
    List<Inscripcion> findByClaseNivelIn(List<ClaseNivel> niveles);
    List<Inscripcion> findByEstadoAndNotaCreditoIsNotNullAndMontoPendienteGreaterThan(String estado, Double montoMinimo);
    Inscripcion findByClienteAndClaseNivel(Cliente cliente, ClaseNivel claseNivel);
    List<Inscripcion> findByClaseNivelAndEstado(ClaseNivel claseNivel, String estado);
    List<Inscripcion> findByClienteId(Integer clienteId);
    boolean existsByClienteIdAndClaseNivelId(Integer clienteId, Integer claseNivelId);
    java.util.Optional<Inscripcion> findByClienteIdAndClaseNivelId(Integer clienteId, Integer claseNivelId);
    boolean existsByClienteAndClaseNivelAndEstado(Cliente cliente, ClaseNivel claseNivel,String estado);
    List<Inscripcion> findByClaseNivelId(Integer claseNivelId);
    @Query("SELECT COUNT(i) > 0 FROM Inscripcion i WHERE i.cliente.id = :clienteId AND i.estado = :estado AND i.claseNivel.id IN (" +
       "SELECT cn.id FROM ClaseNivel cn JOIN cn.horarios h WHERE h.id IN :horarioIds)")
    boolean existeConflictoHorarios(@Param("clienteId") Long clienteId, @Param("horarioIds") List<Integer> horarioIds, @Param("estado") String estado);
    // En InscripcionRepository
    @Query("SELECT i FROM Inscripcion i WHERE i.estado = 'aprobada' AND (:desde IS NULL OR i.fechaInscripcion >= :desde) AND (:hasta IS NULL OR i.fechaInscripcion <= :hasta)")
    List<Inscripcion> findByFechaEntre(@Param("desde") LocalDateTime desdeFecha, @Param("hasta") LocalDateTime hastaFecha);

    long countByClaseNivelId(Integer claseNivelId);
    List<Inscripcion> findByEstadoIgnoreCase(String estado);

}
