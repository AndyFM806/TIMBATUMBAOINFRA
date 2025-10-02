package com.academiabaile.backend.service;

import java.util.List;

import com.academiabaile.backend.entidades.ClienteDTO;

public interface AlumnosPorClaseService {
    public List<ClienteDTO> obtenerAlumnosPorClaseNivel(Integer claseNivelId);

}
