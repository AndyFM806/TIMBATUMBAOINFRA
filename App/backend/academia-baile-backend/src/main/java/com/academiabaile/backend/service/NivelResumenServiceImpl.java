package com.academiabaile.backend.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.academiabaile.backend.entidades.ClaseNivel;
import com.academiabaile.backend.entidades.Horario;
import com.academiabaile.backend.entidades.NivelResumenDTO;
import com.academiabaile.backend.repository.ClaseNivelRepository;
import com.academiabaile.backend.repository.InscripcionRepository;

@Service
public class NivelResumenServiceImpl implements NivelResumenService {

    @Autowired
    private ClaseNivelRepository claseNivelRepository;

    @Autowired
    private InscripcionRepository inscripcionRepository;

    @Override
public List<NivelResumenDTO> obtenerResumenNivelesPorClase(Integer claseId) {
    List<ClaseNivel> niveles = claseNivelRepository.findByClaseId(claseId);

    return niveles.stream().map(nivel -> {
        NivelResumenDTO dto = new NivelResumenDTO();
        dto.setNivel(nivel.getNivel().getNombre());

        // ✅ Obtener todos los horarios directamente
        String horariosStr = nivel.getHorarios().stream()
            .map(Horario::getHora)
            .collect(Collectors.joining(", "));

        dto.setHorario(horariosStr);

        int inscritos = inscripcionRepository.countByClaseNivelAndEstado(nivel, "aprobada");
        dto.setInscritos(inscritos);

        return dto;
    }).collect(Collectors.toList());
}

}
