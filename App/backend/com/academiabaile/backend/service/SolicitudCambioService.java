package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.SolicitudCambio;
import java.util.List;

public interface SolicitudCambioService {
    SolicitudCambio registrarSolicitud(SolicitudCambio solicitud);
    List<SolicitudCambio> listarPendientes();
    List<SolicitudCambio> listarPorUsuario(Long usuarioId);
    SolicitudCambio atenderSolicitud(Long id, String respuesta, boolean aprobar);
    List<SolicitudCambio> listarTodas();

}
