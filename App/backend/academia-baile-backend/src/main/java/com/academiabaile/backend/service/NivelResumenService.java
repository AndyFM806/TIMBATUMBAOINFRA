package com.academiabaile.backend.service;

import java.util.List;

import com.academiabaile.backend.entidades.NivelResumenDTO;

public interface NivelResumenService {
    public List<NivelResumenDTO> obtenerResumenNivelesPorClase(Integer claseId);

}
