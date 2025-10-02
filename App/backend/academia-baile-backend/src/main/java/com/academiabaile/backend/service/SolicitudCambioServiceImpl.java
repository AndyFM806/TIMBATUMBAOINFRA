package com.academiabaile.backend.service;

import com.academiabaile.backend.entidades.ModuloAcceso;
import com.academiabaile.backend.entidades.SolicitudCambio;
import com.academiabaile.backend.entidades.SolicitudCambio.EstadoSolicitud;
import com.academiabaile.backend.entidades.Usuario;
import com.academiabaile.backend.repository.ModuloAccesoRepository;
import com.academiabaile.backend.repository.SolicitudCambioRepository;
import com.academiabaile.backend.repository.UsuarioRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SolicitudCambioServiceImpl implements SolicitudCambioService {

    @Autowired
    private SolicitudCambioRepository solicitudCambioRepository;


    @Autowired
    private UsuarioRepository usuarioRepository;


   @Override
public SolicitudCambio registrarSolicitud(SolicitudCambio solicitud) {
    // ⚠️ Validar que el usuario no sea null y tenga un ID
    if (solicitud.getUsuario() == null || solicitud.getUsuario().getId() == null) {
        throw new IllegalArgumentException("Debe proporcionar un usuario con ID válido.");
    }

    // ✅ Buscar el objeto completo desde la base de datos
    Usuario usuario = usuarioRepository.findById(solicitud.getUsuario().getId())
        .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

    solicitud.setUsuario(usuario);
    solicitud.setEstado(EstadoSolicitud.PENDIENTE);
    solicitud.setFechaCreacion(LocalDateTime.now());

    // Guardar solicitud
    SolicitudCambio guardada = solicitudCambioRepository.save(solicitud);



    return guardada;
}




    @Override
    public List<SolicitudCambio> listarPendientes() {
        return solicitudCambioRepository.findByEstado(EstadoSolicitud.PENDIENTE);
    }

    @Override
    public List<SolicitudCambio> listarPorUsuario(Long usuarioId) {
        return solicitudCambioRepository.findByUsuarioId(usuarioId);
    }

    @Override
    public SolicitudCambio atenderSolicitud(Long id, String respuesta, boolean aprobar) {
        SolicitudCambio solicitud = solicitudCambioRepository.findById(id).orElseThrow();
        solicitud.setRespuesta(respuesta);
        solicitud.setFechaRespuesta(LocalDateTime.now());
        solicitud.setEstado(aprobar ? EstadoSolicitud.ATENDIDA : EstadoSolicitud.RECHAZADA);
        SolicitudCambio actualizada = solicitudCambioRepository.save(solicitud);



        return actualizada;
    }

    @Override
    public List<SolicitudCambio> listarTodas() {
        return solicitudCambioRepository.findAll();
    }
}
