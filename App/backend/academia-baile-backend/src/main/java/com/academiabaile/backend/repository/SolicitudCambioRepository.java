package com.academiabaile.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.academiabaile.backend.entidades.SolicitudCambio;

public interface SolicitudCambioRepository extends JpaRepository<SolicitudCambio, Long> {
    List<SolicitudCambio> findByEstado(SolicitudCambio.EstadoSolicitud estado);
    List<SolicitudCambio> findByUsuarioId(Long usuarioId);
    List<SolicitudCambio> findByUsuarioIdOrderByFechaCreacionDesc(Long usuarioId);

}